#' @export
ms_generic_name <- function(input, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_generic_name")
}

#' @describeIn ms_generic_name For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_generic_name.character <- function(input, force_FC = TRUE) {
  input <- check_character_input(input)

  apply_mapshaper_commands(data = input, command = "-generic_name", force_FC = force_FC)

}

#' @describeIn ms_generic_name Method for geo_json
#' @export
ms_generic_name.geo_json <- function(input, force_FC = TRUE) {
  apply_mapshaper_commands(data = input, command = "-generic_name", force_FC = force_FC)
}

#' @describeIn ms_generic_name Method for geo_list
#' @export
ms_generic_name.geo_list <- function(input, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = "-generic_name", force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @describeIn ms_generic_name Method for SpatialPolygonsDataFrame
#' @export
ms_generic_name.SpatialPolygonsDataFrame <- function(input, force_FC) {
	ms_generic_name_sp(input = input, force_FC = force_FC)
}

#' @describeIn ms_generic_name Method for SpatialLinesDataFrame
#' @export
ms_generic_name.SpatialLinesDataFrame <- function(input, force_FC) {
	ms_generic_name_sp(input = input, force_FC = force_FC)
}

#' @describeIn ms_generic_name Method for SpatialPointsDataFrame
#' @export
ms_generic_name.SpatialPointsDataFrame <- function(input, force_FC) {
	ms_generic_name_sp(input = input, force_FC = force_FC)
}

ms_generic_name_sp <- function(input, force_FC) {
  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(data = geojson, command = "-generic_name", force_FC = TRUE)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}
