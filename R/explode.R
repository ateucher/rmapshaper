#' Convert multipart polygons to singlepart
#'
#' @param x geojson or SpatialPolygonsDataFrame object containing
#'    multipart polygons
#'
#' @return json or SpatialPolygonsDataFrame
#' @export
ms_explode <- function(x) {
  UseMethod("ms_explode")
}

ms_explode.json <- function(x) {
  ret <- apply_mapshaper_commands("-explode", x)
  structure(ret, class = "json")
}

ms_explode.SpatialPolygonsDataFrame <- function(x) {
  geojson <- sp_to_GeoJSON(x)

  ret <- apply_mapshaper_commands("-explode", geojson)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}