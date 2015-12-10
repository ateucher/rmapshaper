#' Delete fields in the attribute table
#'
#' Removes all fields except those listed in the \code{fields} parameter
#'
#' @param input spatial object to filter - can be a \code{Spatial*DataFrame} or
#'   class \code{geo_json} or \code{geo_list}
#' @param fields character vector of fields to retain.
#' @return object with only specified attributes retained, in the same class as
#'   the input
#' @export
ms_filter_fields <- function(input, fields) {
  if (!is.character(fields)) stop("fields must be a character vector")
  UseMethod("ms_filter_fields")
}

#' @describeIn ms_filter_fields For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_filter_fields.character <- function(input, fields) {
  input <- check_character_input(input)

  cmd <- make_filterfields_call(fields)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = FALSE)

}

#' @describeIn ms_filter_fields Method for geo_json
#' @export
ms_filter_fields.geo_json <- function(input, fields) {
  cmd <- make_filterfields_call(fields)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = FALSE)
}

#' @describeIn ms_filter_fields Method for geo_list
#' @export
ms_filter_fields.geo_list <- function(input, fields) {
  geojson <- geojsonio::geojson_json(input)

  cmd <- make_filterfields_call(fields)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = FALSE)

  geojsonio::geojson_list(ret)
}

#' @describeIn ms_filter_fields Method for SpatialPolygonsDataFrame
#' @export
ms_filter_fields.SpatialPolygonsDataFrame <- function(input, fields) {
  ms_filter_fields_sp(input, fields)
}

#' @describeIn ms_filter_fields Method for SpatialPointsDataFrame
#' @export
ms_filter_fields.SpatialPointsDataFrame <- function(input, fields) {
  ms_filter_fields_sp(input, fields)
}

#' @describeIn ms_filter_fields Method for SpatialLinesDataFrame
#' @export
ms_filter_fields.SpatialLinesDataFrame <- function(input, fields) {
  ms_filter_fields_sp(input, fields)
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
