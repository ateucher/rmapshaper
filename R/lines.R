
#' Convert polygons to topological boundaries (lines)
#'
#' @param input input polygons object to convert to inner lines. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{geo_list} polygons;
#'  \item \code{SpatialPolygons*};
#'  \item \code{sf} or \code{sfc} polygons object
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
#' @param sys Should the system mapshaper be used instead of the bundled mapshaper? Gives
#'   better performance on large files. Requires the mapshaper node package to be installed
#'   and on the PATH.
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
ms_lines <- function(input, fields = NULL, force_FC = TRUE, sys = FALSE) {
  if (!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_lines")
}

#' @export
ms_lines.character <- function(input, fields = NULL, force_FC = TRUE, sys = FALSE) {
  input <- check_character_input(input)

  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, force_FC = force_FC,
                           sys = sys)

}

#' @export
ms_lines.geo_json <- function(input, fields = NULL, force_FC = TRUE, sys = FALSE) {
  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, force_FC = force_FC,
                           sys = sys)
}

#' @export
ms_lines.geo_list <- function(input, fields = NULL, force_FC = TRUE, sys = FALSE) {
  geojson <- geo_list_to_json(input)

  command <- make_lines_call(fields)

  ret <- apply_mapshaper_commands(data = geojson, command = command,
                                  force_FC = force_FC, sys = sys)

  geojsonio::geojson_list(ret)
}

#' @export
ms_lines.SpatialPolygons <- function(input, fields = NULL, force_FC, sys = FALSE) {

  if (.hasSlot(input, "data")) {
    if (!all(fields %in% names(input@data))) {
      stop("not all fields specified exist in input data")
    }
  }

  command <- make_lines_call(fields)

  ms_sp(input, command, sys = sys)
}

#' @export
ms_lines.sf <- function(input, fields = NULL, force_FC, sys = FALSE) {

  if (!all(fields %in% names(input))) {
    stop("not all fields specified exist in input data")
  }

  lines_sf(input = input, fields = fields, sys = sys)
}

#' @export
ms_lines.sfc <- function(input, fields = NULL, force_FC, sys = FALSE) {

  if (!is.null(fields)) {
    stop("Do not specify fields for sfc classes", call. = FALSE)
  }

  lines_sf(input = input, fields = fields, sys = sys)
}

lines_sf <- function(input, fields, sys) {
  if (!all(sf::st_is(input, c("POLYGON", "MULTIPOLYGON")))) {
    stop("ms_lines only works with (MULTI)POLYGON")
  }

  command <- make_lines_call(fields)

  ms_sf(input, command, sys = sys)
}

make_lines_call <- function(fields) {
  if(!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")

  fields <- paste0(fields, collapse = ",")

  call <- list("-lines", fields)
  call
}

