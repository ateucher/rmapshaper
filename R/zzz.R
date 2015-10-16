#' apply_mapshaper_commands
#'
#' @param command command string
#' @param data geojson object
#'
#' @return geojson
#' @export
apply_mapshaper_commands <- function(command, data) {
  ms$eval("var return_data;")

  callback <- "function(Error, data) {
  if (Error) console.error(Error);
  return_data = data;
}"

  ms$call("mapshaper.applyCommands", command, data, JS(callback))
  ms$get("return_data")
}

#' @importFrom rgdal readOGR writeOGR
#' @importFrom sp proj4string proj4string<- CRS
GeoJSON_to_sp <- function(geojson, proj) {
  sp <- suppressMessages(readOGR(geojson, "OGRGeoJSON", verbose = FALSE))
  suppressMessages(suppressWarnings(proj4string(sp) <- CRS(proj)))
  sp
}

#' @importFrom geojsonio geojson_json
sp_to_GeoJSON <- function(sp){
  proj <- proj4string(sp)
  js <- geojson_json(sp)
  structure(js, proj4 = proj)
}
