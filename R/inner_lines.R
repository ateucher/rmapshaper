#' Create a line layer consisting of shared boundaries with no attribute data
#'
#' @param input input polygons object to convert to inner lines - can be a
#'   \code{SpatialPolygons*} or class \code{geo_json} or
#'   \code{geo_list}
#' @param force_FC should the output be forced to be a \code{FeatureCollection}
#'   even if there are no attributes? Default \code{TRUE}.
#'   \code{FeatureCollections} are more compatible with \code{rgdal::readOGR}
#'   and \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no
#'   attributes associated with the geometries, a \code{GeometryCollection} will
#'   be output. Ignored for \code{Spatial} objects, as the output is always the 
#'   same class as input.
#'
#' @return lines in the same class as the input layer
#' @export
ms_innerlines <- function(input, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_innerlines")
}

#' @describeIn ms_innerlines For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_innerlines.character <- function(input, force_FC = TRUE) {
  input <- check_character_input(input)

  apply_mapshaper_commands(data = input, command = "-innerlines", force_FC = force_FC)

}

#' @describeIn ms_innerlines Method for geo_json
#' @export
ms_innerlines.geo_json <- function(input, force_FC = TRUE) {
  apply_mapshaper_commands(data = input, command = "-innerlines", force_FC = force_FC)
}

#' @describeIn ms_innerlines Method for geo_list
#' @export
ms_innerlines.geo_list <- function(input, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = "-innerlines", force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @describeIn ms_innerlines Method for SpatialPolygons
#' @export
ms_innerlines.SpatialPolygons <- function(input, force_FC) {
	ms_sp(input, "-innerlines", out_class = "SpatialLines")
}

