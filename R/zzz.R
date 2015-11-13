#' Apply a mapshaper command string to a geojson object
#'
#' @param command command string
#' @param data geojson object
#'
#' @return geojson
#' @export
apply_mapshaper_commands <- function(command, data) {

  if (!jsonlite::validate(data)) stop("Not a valid json object!")

  ## Create a JS object to hold the returned data
  ms$eval("var return_data;")

  ## create a JS callback function
  callback <- "function(Error, data) {
  if (Error) console.error(Error);
  return_data = data;
}"

  ms$call("mapshaper.applyCommands", command, data, JS(callback))
  ret <- ms$get("return_data")
  structure(ret, class = "json")
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

geojson_to_geo_list <- function(json) {
  ret_list <- geojson_list(json)
  ## Won't need this line soon, in dev version of geojsonio outputs from
  ## geojson_list are tagged with geo_list class (geojsonio PR #68)
  structure(ret_list, class = "geo_list")
}
