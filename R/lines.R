
#' Convert polygons to topological boundaries (lines)
#'
#' @param input input polygons object to convert to inner lines. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{SpatialPolygons*};
#'  \item \code{sf} or \code{sfc} polygons object
#'  }
#' @param fields character vector of field names. If left as \code{NULL}
#'   (default), external (unshared) boundaries are attributed as TYPE 0 and
#'   internal (shared) boundaries are TYPE 1. Giving a field name adds an
#'   intermediate level of hierarchy at TYPE 1, with the lowest-level internal
#'   boundaries set to TYPE 2. Supplying a character vector of field names adds
#'   additional levels of hierarchy.
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet
#'
#' @return topological boundaries as lines, in the same class as the input
#'
#' @examples
#'
#' library(geojsonsf)
#' library(sf)
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
#'              ]]}}]}', class = c("geojson", "json"))
#'
#' poly <- geojson_sf(poly)
#' summary(poly)
#' plot(poly)
#'
#' out <- ms_lines(poly)
#' summary(out)
#' plot(out)
#'
#' @export
ms_lines <- function(input, fields = NULL, ...) {
  if (!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")
  UseMethod("ms_lines")
}

#' @export
ms_lines.character <- function(input, fields = NULL, ...) {
  input <- check_character_input(input)

  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, ...)

}

#' @export
ms_lines.json <- function(input, fields = NULL, ...) {
  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, ...)
}

#' @export
ms_lines.SpatialPolygons <- function(input, fields = NULL, ...) {

  if (.hasSlot(input, "data")) {
    if (!all(fields %in% names(input@data))) {
      stop("not all fields specified exist in input data")
    }
  }

  command <- make_lines_call(fields)

  ms_sp(input, command, ...)
}

#' @export
ms_lines.sf <- function(input, fields = NULL, ...) {

  if (!all(fields %in% names(input))) {
    stop("not all fields specified exist in input data")
  }

  lines_sf(input = input, fields = fields, ...)
}

#' @export
ms_lines.sfc <- function(input, fields = NULL, ...) {

  if (!is.null(fields)) {
    stop("Do not specify fields for sfc classes", call. = FALSE)
  }

  lines_sf(input = input, fields = fields, ...)
}

lines_sf <- function(input, fields, ...) {
  if (!all(sf::st_is(input, c("POLYGON", "MULTIPOLYGON")))) {
    stop("ms_lines only works with (MULTI)POLYGON")
  }

  command <- make_lines_call(fields)

  ms_sf(input, command, ...)
}

make_lines_call <- function(fields) {
  if(!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")

  fields <- paste0(fields, collapse = ",")

  call <- list("-lines", fields)
  call
}

