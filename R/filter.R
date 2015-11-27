#' Filter features based on attributes
#'
#' Apply a boolean expression to the attributes of each feature, removeing those
#' which evaluate to \code{FALSE}
#'
#' @param input spatial object to filter - can be one of the \code{Spatial}
#'   classes (e.g., \code{SpatialPolygonsDataFrame}) or class \code{geo_json}
#' @param filter expression to apply. Can be a character vector of individual
#'   expressions, which will be combined with logical \code{AND (&)}, or a
#'   single string combing expressions with \code{&} and/or \code{|}.
#' @param force_FC should the output be forced to be a \code{FeatureCollection}
#'   even if there are no attributes? Default \code{TRUE}.
#'   \code{FeatureCollections} are more compatible with \code{rgdal::readOGR}
#'   and \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no
#'   attributes associated with the geometries, a \code{GeometryCollection} will
#'   be output. Ignored for \code{Spatial} objects, as a
#'   \code{Spatial*DataFrame} is always the output.
#'
#' @return object with only specified features retained, in the same class as the input
#' @export
ms_filter <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_filter")
}

#' @describeIn ms_filter For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_filter.character <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC = TRUE) {
  input <- check_character_input(input)

  cmd <- make_filter_call(filter, remove_null_geometries)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)

}

#' @describeIn ms_filter Method for geo_json
#' @export
ms_filter.geo_json <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC = TRUE) {
  cmd <- make_filter_call(filter, remove_null_geometries)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)
}

#' @describeIn ms_filter Method for geo_list
#' @export
ms_filter.geo_list <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  cmd <- make_filter_call(filter, remove_null_geometries)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @describeIn ms_filter Method for SpatialPolygonsDataFrame
#' @export
ms_filter.SpatialPolygonsDataFrame <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC) {
	ms_filter_sp(input = input, filter = filter, force_FC = force_FC)
}

#' @describeIn ms_filter Method for SpatialLinesDataFrame
#' @export
ms_filter.SpatialLinesDataFrame <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC) {
	ms_filter_sp(input = input, filter = filter, force_FC = force_FC)
}

#' @describeIn ms_filter Method for SpatialPointsDataFrame
#' @export
ms_filter.SpatialPointsDataFrame <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC) {
	ms_filter_sp(input = input, filter = filter, force_FC = force_FC)
}

ms_filter_sp <- function(input, filter = NULL, remove_null_geometries = TRUE, force_FC) {

  cmd <- make_filter_call(filter, remove_null_geometries)

  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = TRUE)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}

make_filter_call <- function(filter, remove_null_geometries) {
  # ==, >, >=, <, <=, is.na, !
  # http://www.w3schools.com/js/js_comparisons.asp
  if (remove_null_geometries) rem <- "remove-empty" else rem <- NULL
  ## Convert R-style single & / | to js-style && / ||
  filter <- gsub("\\&+", "&&", filter)
  filter <- gsub("\\|+", "||", filter)
  ## If more than one conditional statement, combine with &&
  if (length(filter) > 1) {
    filter <- paste0("(", filter, ")")
    filter <- paste0(filter, collapse = " && ")
  }
  call <- list("-filter", rem, paste0("'", filter, "'"))
  call
}
