#' Convert multipart polygons to singlepart
#'
#' For objects of class Spatial (e.g., SpatialPolygonsDataFrame), this is
#' simply a wrapper around sp::disaggregate.
#'
#' @param input geojson or SpatialPolygonsDataFrame object containing
#'    multipart polygons
#' @param force_FC should the geojson output be forced to be a FeatureCollection
#'  even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If \code{FALSE} and there are no attributes associated with
#'  the geometries, a GeometryCollection will be output. Not used for
#'  \code{Spatial} objects.
#'
#' @return geo_json or SpatialPolygonsDataFrame
#' @export
ms_explode <- function(input, force_FC = TRUE) {
  UseMethod("ms_explode")
}

#' @export
ms_explode.geo_json <- function(input, force_FC = TRUE) {
  apply_mapshaper_commands(data = input, command = "-explode", force_FC = force_FC)
}

## The method using mapshaper's explode works, but is waaaay slower than
## sp::disaggregate due to converstion to/from geojson
#' @export
ms_explode.SpatialPolygonsDataFrame <- function(input, force_FC) {
  sp::disaggregate(input)
}
# ms_explode.SpatialPolygonsDataFrame <- function(input) {
#   geojson <- sp_to_GeoJSON(input)
#
#   ret <- apply_mapshaper_commands(data = geojson, command = "-explode")
#
#   GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
# }

#' @export
ms_explode.geo_list <- function(input, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = "-explode", force_FC = force_FC)

  geojsonio::geojson_list(ret)
}