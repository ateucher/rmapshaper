#' Apply a mapshaper command string to a geojson object
#'
#' @param data geojson object
#' @param command valid mapshaper command string
#' @param force_FC should the output be forced to be a FeatureCollection (or
#'  Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'  the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'  will be output.
#'
#' @return geojson
#' @export
apply_mapshaper_commands <- function(data, command, force_FC) {

  if (!jsonlite::validate(data)) stop("Not a valid geo_json object!")

  ## Add a dummy id to make sure object is a FeatureCollection, otherwise
  ## a GeometryCollection will be returned, which readOGR doesn't usually like.
  ## See discussion here: https://github.com/mbloch/mapshaper/issues/99.
  if (force_FC) {
    add_id <- add_dummy_id_command()
  } else {
    add_id <- NULL
  }

  command <- c(command, add_id)

  command <- paste(ms_compact(command), collapse = " ")

  ## Create a JS object to hold the returned data
  ms$eval("var return_data;")

  ## create a JS callback function
  callback <- "function(Error, data) {
  if (Error) console.error(Error);
  return_data = data;
}"

  ms$call("mapshaper.applyCommands", command, data, V8::JS(callback))
  ret <- ms$get("return_data")
  class_geo_json(ret)
}

GeoJSON_to_sp <- function(geojson, proj = NULL) {
  sp <- suppressWarnings(
    suppressMessages(
    rgdal::readOGR(geojson, "OGRGeoJSON", verbose = FALSE,
                   disambiguateFIDs = TRUE, p4s = proj)
    ))
  sp
}

sp_to_GeoJSON <- function(sp){
  proj <- sp::proj4string(sp)
  js <- geojsonio::geojson_json(sp)
  structure(js, proj4 = proj)
}

ms_compact <- function(l) Filter(Negate(is.null), l)

add_dummy_id_command <- function() {
  "-each 'rmapshaperid = $.id'"
}

class_geo_json <- function(x) {
  structure(x, class = c("json", "geo_json"))
}

class_geo_list <- function(x) {
  class_geo_json <- function(x) {
    structure(x, class = "geo_list")
  }
}

# x is a geo_list
drop_null_geometries <- function(x) {
  features_to_keep <- vapply(x$features,
                          function(y) !is.null(y$geometry),
                          logical(1))
  x$features <- x$features[features_to_keep]
  x
}
