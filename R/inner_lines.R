#' Create a line layer consisting of shared boundaries with no attribute data
#'
#' @param input input polygons object to convert to inner lines. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{geo_list} polygons;
#'  \item \code{SpatialPolygons*}
#'  }
#' @param force_FC should the output be forced to be a \code{FeatureCollection}
#'   even if there are no attributes? Default \code{TRUE}.
#'   \code{FeatureCollections} are more compatible with \code{rgdal::readOGR}
#'   and \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no
#'   attributes associated with the geometries, a \code{GeometryCollection} will
#'   be output. Ignored for \code{Spatial} objects.
#'
#' @return lines in the same class as the input layer
#'
#' @examples
#' library(geojsonio)
#' library(sp)
#'
#' poly <- structure('{"type":"FeatureCollection",
#'             "features":[
#'               {"type":"Feature",
#'                 "properties":{"foo": "a"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [102,2],[102,3],[103,3],[103,2],[102,2]
#'                   ]]}}
#'               ,{"type":"Feature",
#'                 "properties":{"foo": "a"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [103,3],[104,3],[104,2],[103,2],[103,3]
#'                   ]]}},
#'               {"type":"Feature",
#'                 "properties":{"foo": "b"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [102,1],[102,2],[103,2],[103,1],[102,1]
#'                   ]]}},
#'               {"type":"Feature",
#'                 "properties":{"foo": "b"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [103,1],[103,2],[104,2],[104,1],[103,1]
#'                   ]]}}]}', class = c("json", "geo_json"))
#'
#' poly <- geojson_sp(poly)
#' plot(poly)
#'
#' out <- ms_innerlines(poly)
#' plot(out)
#'
#' @export
ms_innerlines <- function(input, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_innerlines")
}

#' @export
ms_innerlines.character <- function(input, force_FC = TRUE) {
  input <- check_character_input(input)

  apply_mapshaper_commands(data = input, command = "-innerlines", force_FC = force_FC)

}

#' @export
ms_innerlines.geo_json <- function(input, force_FC = TRUE) {
  apply_mapshaper_commands(data = input, command = "-innerlines", force_FC = force_FC)
}

#' @export
ms_innerlines.geo_list <- function(input, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = "-innerlines", force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @export
ms_innerlines.SpatialPolygons <- function(input, force_FC) {
	ms_sp(input, "-innerlines", out_class = "SpatialLines")
}

