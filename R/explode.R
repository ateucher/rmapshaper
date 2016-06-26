#' Convert multipart lines or polygons to singlepart
#'
#' For objects of class \code{Spatial} (e.g., \code{SpatialPolygonsDataFrame}),
#' you may find it faster to use \code{sp::disaggregate}.
#'
#' There is currently no method for SpatialMultiPoints
#'
#' @param input One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} multipart lines, or polygons;
#'  \item \code{geo_list} multipart lines, or polygons;
#'  \item multipart \code{SpatialPolygons}, \code{SpatialLines}
#' }
#' @param force_FC should the output be forced to be a \code{FeatureCollection} even
#' if there are no attributes? Default \code{TRUE}.
#'  \code{FeatureCollections} are more compatible with \code{rgdal::readOGR} and
#'  \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no attributes associated with
#'  the geometries, a \code{GeometryCollection} will be output. Ignored for \code{Spatial}
#'  objects, as the output is always the same class as the input.
#'
#' @return same class as input
#'
#' @examples
#' library(geojsonio)
#' library(sp)
#'
#' poly <- structure("{\"type\":\"FeatureCollection\",\"crs\":
#'           {\"type\":\"name\",\"properties\":{\"name\":
#'           \"urn:ogc:def:crs:OGC:1.3:CRS84\"}},\"features\":
#'           [\n{\"type\":\"Feature\",\"geometry\":{\"type\":
#'           \"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],
#'           [103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],
#'           [101,0],[100,0]]]]},\"properties\":{\"rmapshaperid\":0}}\n]}",
#'           class = c("json", "geo_json"))
#'
#' poly <- geojson_sp(poly)
#' plot(poly)
#' length(poly)
#' poly@data
#'
#' # Explode the polygon
#' out <- ms_explode(poly)
#' plot(out)
#' length(out)
#' out@data
#'
#' @export
ms_explode <- function(input, force_FC = TRUE) {
  UseMethod("ms_explode")
}

#' @export
ms_explode.character <- function(input, force_FC = TRUE) {
  input <- check_character_input(input)

  apply_mapshaper_commands(data = input, command = "-explode", force_FC = force_FC)

}

#' @export
ms_explode.geo_json <- function(input, force_FC = TRUE) {
  apply_mapshaper_commands(data = input, command = "-explode", force_FC = force_FC)
}

#' @export
ms_explode.geo_list <- function(input, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = "-explode", force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

## The method using mapshaper's explode works, but is waaaay slower than
## sp::disaggregate due to converstion to/from geojson

#' @export
ms_explode.SpatialPolygons <- function(input, force_FC = TRUE) {
  explode_sp(input)
}

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
