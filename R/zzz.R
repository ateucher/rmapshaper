#' Apply a mapshaper command string to a geojson object
#'
#' @param command command string
#' @param data geojson object
#' @param force_FC should the output be forced to be a FeatureCollection (or
#'  Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'  the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'  will be output.
#'
#' @return geojson
#' @export
apply_mapshaper_commands <- function(command, data, force_FC) {

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

  ms$call("mapshaper.applyCommands", command, data, JS(callback))
  ret <- ms$get("return_data")
  structure(ret, class = c("json", "geo_json"))
}

#' @importFrom rgdal readOGR writeOGR
#' @importFrom sp proj4string proj4string<- CRS get_ReplCRS_warn set_ReplCRS_warn
GeoJSON_to_sp <- function(geojson, proj) {
  repl_crs_warn_val <- get_ReplCRS_warn()
  on.exit(set_ReplCRS_warn(repl_crs_warn_val))

  set_ReplCRS_warn(FALSE)
  sp <- suppressMessages(readOGR(geojson, "OGRGeoJSON", verbose = FALSE,
                                 disambiguateFIDs = TRUE))
  suppressMessages(proj4string(sp) <- CRS(proj))
  sp
}

#' @importFrom geojsonio geojson_json
sp_to_GeoJSON <- function(sp){
  proj <- proj4string(sp)
  js <- geojson_json(sp)
  structure(js, proj4 = proj)
}

ms_compact <- function(l) Filter(Negate(is.null), l)

add_dummy_id_command <- function() {
  "-each 'rmapshaperid = $.id'"
}

