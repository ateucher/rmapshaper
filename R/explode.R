#' Convert multipart polygons to singlepart
#'
#' @param input geojson or SpatialPolygonsDataFrame object containing
#'    multipart polygons
#'
#' @return json or SpatialPolygonsDataFrame
#' @export
ms_explode <- function(input) {
  UseMethod("ms_explode")
}

ms_explode.json <- function(input) {
  apply_mapshaper_commands("-explode", input)
}

ms_explode.SpatialPolygonsDataFrame <- function(input) {
  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands("-explode", geojson)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}