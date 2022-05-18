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
#'  \item multipart \code{SpatialPolygons}, \code{SpatialLines};
#'  \item \code{sf} or \code{sfc} multipart lines, or polygons object
#' }
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet
#'
#' @return same class as input
#'
#' @examples
#' library(geojsonsf)
#' library(sf)
#'
#' poly <- "{\"type\":\"FeatureCollection\",\"features\":
#'           [\n{\"type\":\"Feature\",\"geometry\":{\"type\":
#'           \"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],
#'           [103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],
#'           [101,0],[100,0]]]]},\"properties\":{\"a\":0}}\n]}"
#'
#' poly <- geojson_sf(poly)
#' plot(poly)
#' length(poly)
#' poly
#'
#' # Explode the polygon
#' out <- ms_explode(poly)
#' plot(out)
#' length(out)
#' out
#'
#' @export
ms_explode <- function(input, ...) {
  UseMethod("ms_explode")
}

#' @export
ms_explode.character <- function(input, ...) {
  input <- check_character_input(input)

  apply_mapshaper_commands(data = input, command = "-explode", ...)

}

#' @export
ms_explode.json <- function(input, ...) {
  apply_mapshaper_commands(data = input, command = "-explode", ...)
}

## The method using mapshaper's explode works, but is waaaay slower than
## sp::disaggregate due to converstion to/from geojson

#' @export
ms_explode.SpatialPolygons <- function(input, ...) {
  explode_sp(input, ...)
}

#' @export
ms_explode.SpatialLines <- function(input, ...) {
  explode_sp(input, ...)
}

# #' @describeIn ms_explode Method for SpatialPoints
# #' @export
# ms_explode.SpatialPoints <- function(input, force_FC = TRUE) {
#   explode_sp(input, force_FC)
# }

explode_sp <- function(input, ...) {
 ms_sp(input = input, call = "-explode", ...)
}

#' @export
ms_explode.sf <- function(input, ...) {
  explode_sf(input = input, ...)
}

#' @export
ms_explode.sfc <- function(input, ...) {
  explode_sf(input = input, ...)
}

explode_sf <- function(input, ...) {
  ms_sf(input = input, call = "-explode", ...)
}
