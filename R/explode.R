#' Convert multipart polygons to singlepart
#'
#' For objects of class \code{Spatial} (e.g., \code{SpatialPolygonsDataFrame}), this is
#' simply a wrapper around \code{sp::disaggregate}.
#'
#' @param input \code{geojson} or \code{SpatialPolygonsDataFrame} object containing
#'    multipart polygons
#' @param force_FC should the output be forced to be a \code{FeatureCollection} even
#' if there are no attributes? Default \code{TRUE}.
#'  \code{FeatureCollections} are more compatible with \code{rgdal::readOGR} and
#'  \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no attributes associated with
#'  the geometries, a \code{GeometryCollection} will be output. Ignored for \code{Spatial}
#'  objects, as a \code{Spatial*DataFrame} is always the output.
#'
#' @return same class as input
#' @export
ms_explode <- function(input, force_FC = TRUE) {
  UseMethod("ms_explode")
}

#' @describeIn ms_explode For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_explode.character <- function(input, force_FC = TRUE) {
  input <- check_character_input(input)

  apply_mapshaper_commands(data = input, command = "-explode", force_FC = force_FC)

}

#' @describeIn ms_explode Method for geo_json
#' @export
ms_explode.geo_json <- function(input, force_FC = TRUE) {
  apply_mapshaper_commands(data = input, command = "-explode", force_FC = force_FC)
}

#' @describeIn ms_explode Method for geo_list
#' @export
ms_explode.geo_list <- function(input, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = "-explode", force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

## The method using mapshaper's explode works, but is waaaay slower than
## sp::disaggregate due to converstion to/from geojson

#' @describeIn ms_explode Method for SpatialPolygonsDataFrame
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

#' @describeIn ms_explode Method for SpatialLinesDataFrame
#' @export
ms_explode.SpatialLinesDataFrame <- function(input, force_FC) {
  sp::disaggregate(input)
}

# #' @describeIn ms_explode Method for SpatialPointsDataFrame
# #' @export
# ms_explode.SpatialPointsDataFrame <- function(input, force_FC) {
#   sp::disaggregate(input)
# }
