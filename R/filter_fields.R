#' Delete fields in the attribute table
#'
#' Removes all fields except those listed in the \code{fields} parameter
#'
#' @param input spatial object to filter fields on. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} points, lines, or polygons;
#'  \item \code{geo_list} points, lines, or polygons;
#'  \item \code{SpatialPolygonsDataFrame}, \code{SpatialLinesDataFrame}, \code{SpatialPointsDataFrame};
#'  \item \code{sf} object
#'  }
#' @param fields character vector of fields to retain.
#' @return object with only specified attributes retained, in the same class as
#'   the input
#'
#' @examples
#' library(geojsonio)
#' library(sp)
#'
#' poly <- structure("{\"type\":\"FeatureCollection\",
#'                   \"features\":[{\"type\":\"Feature\",
#'                   \"properties\":{\"a\": 1, \"b\":2, \"c\": 3},
#'                   \"geometry\":{\"type\":\"Polygon\",
#'                   \"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}}]}",
#'                   class = c("json", "geo_json"))
#' poly <- geojson_sp(poly)
#' poly@data
#'
#' # Filter (keep) fields a and b, drop c
#' out <- ms_filter_fields(poly, c("a", "b"))
#' out@data
#'
#' @export
ms_filter_fields <- function(input, fields) {
  if (!is.character(fields)) stop("fields must be a character vector")
  UseMethod("ms_filter_fields")
}

#' @export
ms_filter_fields.character <- function(input, fields) {
  input <- check_character_input(input)

  cmd <- make_filterfields_call(fields)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = FALSE)
}

#' @export
ms_filter_fields.geo_json <- function(input, fields) {
  cmd <- make_filterfields_call(fields)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = FALSE)
}

#' @export
ms_filter_fields.geo_list <- function(input, fields) {
  geojson <- geojsonio::geojson_json(input)

  cmd <- make_filterfields_call(fields)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = FALSE)

  geojsonio::geojson_list(ret)
}

#' @export
ms_filter_fields.SpatialPolygonsDataFrame <- function(input, fields) {
  ms_filter_fields_sp(input, fields)
}

#' @export
ms_filter_fields.SpatialPointsDataFrame <- function(input, fields) {
  ms_filter_fields_sp(input, fields)
}

#' @export
ms_filter_fields.SpatialLinesDataFrame <- function(input, fields) {
  ms_filter_fields_sp(input, fields)
}

#' @export
ms_filter_fields.sf <- function(input, fields) {
  if (!all(fields %in% names(input))) {
    stop("Not all fields are in input")
  }

  # call <- make_filterfields_call(fields)
  #
  # ms_sf(input = input, call = call)

  check_sf_pkg()

  input[, fields, drop = FALSE]
}

ms_filter_fields_sp <- function(input, fields) {

  # cmd <- make_filterfields_call(fields)
  #
  # geojson <- sp_to_GeoJSON(input)
  #
  # ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = FALSE)
  #
  # GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))

  if (!(all(is.element(fields, names(input@data))))) {
    stop("Not all named fields exist in input data", call. = FALSE)
  }

  input@data <- input@data[, fields]

  input

}

make_filterfields_call <- function(fields) {
  call <- list("-filter-fields", paste0(fields, collapse = ","))
  call
}

