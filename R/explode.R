#' Convert multipart polygons to singlepart
#'
#' For objects of class \code{Spatial} (e.g., \code{SpatialPolygonsDataFrame}),
#' you may find it faster to use \code{sp::disaggregate}.
#'
#' There is currently no method for spatialMultiPoints
#'
#' @param input \code{geojson} or \code{Spatial*} object containing
#'    multipart polygons or lines
#' @param force_FC should the output be forced to be a \code{FeatureCollection} even
#' if there are no attributes? Default \code{TRUE}.
#'  \code{FeatureCollections} are more compatible with \code{rgdal::readOGR} and
#'  \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no attributes associated with
#'  the geometries, a \code{GeometryCollection} will be output. Ignored for \code{Spatial}
#'  objects, as the output is always the same class as the input.
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

#' @describeIn ms_explode Method for SpatialPolygons
#' @export
ms_explode.SpatialPolygons <- function(input, force_FC = TRUE) {
  explode_sp(input)
}

#' @describeIn ms_explode Method for SpatialLines
#' @export
ms_explode.SpatialLines <- function(input, force_FC = TRUE) {
  explode_sp(input)
}

# #' @describeIn ms_explode Method for SpatialPoints
# #' @export
# ms_explode.SpatialPoints <- function(input, force_FC = TRUE) {
#   explode_sp(input, force_FC)
# }

explode_sp <- function(input) {
 ms_sp(input = input, call = "-explode")
}
