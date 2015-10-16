#' Apply a mapshaper command string to a geojson object
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
  ret <- ms$get("return_data")
  structure(ret, class = "json")
}

#' @importFrom rgdal readOGR writeOGR
#' @importFrom sp proj4string proj4string<- CRS get_ReplCRS_warn set_ReplCRS_warn
GeoJSON_to_sp <- function(geojson, proj) {
  repl_crs_warn_val <- get_ReplCRS_warn()
  on.exit(set_ReplCRS_warn(repl_crs_warn_val))

  set_ReplCRS_warn(FALSE)
  sp <- suppressMessages(readOGR(geojson, "OGRGeoJSON", verbose = FALSE))
  suppressMessages(proj4string(sp) <- CRS(proj))
  sp
}

#' @importFrom geojsonio geojson_json
sp_to_GeoJSON <- function(sp){
  proj <- proj4string(sp)
  js <- geojson_json(sp)
  structure(js, proj4 = proj)
}
