
#' Convert polygons to topological boundaries (lines)
#'
#' @param input input polygons object to convert to inner lines. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{geo_list} polygons;
#'  \item \code{SpatialPolygons*}
#'  }
#' @param fields character vector of field names. If left as \code{NULL}
#'   (default), external (unshared) boundaries are attributed as TYPE 0 and
#'   internal (shared) boundaries are TYPE 1. Giving a field name adds an
#'   intermediate level of hierarchy at TYPE 1, with the lowest-level internal
#'   boundaries set to TYPE 2. Supplying a character vector of field names adds
#'   additional levels of hierarchy.
#' @param force_FC should the output be forced to be a \code{FeatureCollection}
#'   even if there are no attributes? Default \code{TRUE}.
#'   \code{FeatureCollections} are more compatible with \code{rgdal::readOGR}
#'   and \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no
#'   attributes associated with the geometries, a \code{GeometryCollection} will
#'   be output. Ignored for \code{Spatial} objects.
#'
#' @return topological boundaries as lines, in the same class as the input
#'
#' @examples
#'
#' library(geojsonio)
#' library(sp)
#'
#' poly <- structure('{"type":"FeatureCollection",
#'              "features":[
#'              {"type":"Feature",
#'              "properties":{"foo": "a"},
#'              "geometry":{"type":"Polygon","coordinates":[[
#'              [102,2],[102,3],[103,3],[103,2],[102,2]
#'              ]]}}
#'              ,{"type":"Feature",
#'              "properties":{"foo": "a"},
#'              "geometry":{"type":"Polygon","coordinates":[[
#'              [103,3],[104,3],[104,2],[103,2],[103,3]
#'              ]]}},
#'              {"type":"Feature",
#'              "properties":{"foo": "b"},
#'              "geometry":{"type":"Polygon","coordinates":[[
#'              [102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]
#'              ]]}}]}', class = c("json", "geo_json"))
#'
#' poly <- geojson_sp(poly)
#' summary(poly)
#' plot(poly)
#'
#' out <- ms_lines(poly)
#' summary(out)
#' plot(out)
#'
#' @export
ms_lines <- function(input, fields = NULL, force_FC = TRUE) {
  if (!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_lines")
}

#' @export
ms_lines.character <- function(input, fields = NULL, force_FC = TRUE) {
  input <- check_character_input(input)

  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, force_FC = force_FC)

}

#' @export
ms_lines.geo_json <- function(input, fields = NULL, force_FC = TRUE) {
  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, force_FC = force_FC)
}

#' @export
ms_lines.geo_list <- function(input, fields = NULL, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  command <- make_lines_call(fields)

  ret <- apply_mapshaper_commands(data = geojson, command = command, force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @export
ms_lines.SpatialPolygons <- function(input, fields = NULL, force_FC) {

  if (.hasSlot(input, "data")) {
    if (!all(fields %in% names(input@data))) {
      stop("not all fields specified exist in input data")
    }
  }

  command <- make_lines_call(fields)

  ms_sp(input, command, out_class = "SpatialLines")
}

make_lines_call <- function(fields) {
  if(!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")

  fields <- paste0(fields, collapse = ",")

  call <- list("-lines", fields)
  call
}

