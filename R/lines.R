
#' Convert polygons to topological boundaries (lines)
#'
#' @param input polygons object to dissolve - can be a
#'   \code{SpatialPolygonsDataFrame} or class \code{geo_json} or
#'   \code{geo_list}
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
#'   be output. Ignored for \code{Spatial} objects, as a
#'   \code{SpatialLinesDataFrame} is always the output.
#'
#' @return
#' @export
ms_lines <- function(input, fields = NULL, force_FC = TRUE) {
  if (!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_lines")
}

#' @describeIn ms_lines For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_lines.character <- function(input, fields = NULL, force_FC = TRUE) {
  input <- check_character_input(input)

  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, force_FC = force_FC)

}

#' @describeIn ms_lines Method for geo_json
#' @export
ms_lines.geo_json <- function(input, fields = NULL, force_FC = TRUE) {
  command <- make_lines_call(fields)

  apply_mapshaper_commands(data = input, command = command, force_FC = force_FC)
}

#' @describeIn ms_lines Method for geo_list
#' @export
ms_lines.geo_list <- function(input, fields = NULL, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  command <- make_lines_call(fields)

  ret <- apply_mapshaper_commands(data = geojson, command = command, force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @describeIn ms_lines Method for SpatialPolygonsDataFrame
#' @export
ms_lines.SpatialPolygonsDataFrame <- function(input, fields = NULL, force_FC) {

  if (!all(fields %in% names(input@data))) stop("not all fields specified exist in input data")

  command <- make_lines_call(fields)

  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(data = geojson, command = command, force_FC = TRUE)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}

make_lines_call <- function(fields) {
  if(!is.null(fields) && !is.character(fields)) stop("fields must be a character vector of field names")

  fields <- paste0(fields, collapse = ",")

  call <- list("-lines", fields)
  call
}

