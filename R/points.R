#' @export
ms_points <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_points")
}

#' @describeIn ms_points For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_points.character <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  input <- check_character_input(input)

  cmd <- make_points_call(location = location, x = x, y = y)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)

}

#' @describeIn ms_points Method for geo_json
#' @export
ms_points.geo_json <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  cmd <- make_points_call(location = location, x = x, y = y)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)
}

#' @describeIn ms_points Method for geo_list
#' @export
ms_points.geo_list <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  cmd <- make_points_call(location = location, x = x, y = y)

  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @describeIn ms_points Method for SpatialPolygonsDataFrame
#' @export
ms_points.SpatialPolygonsDataFrame <- function(input, location = NULL, x = NULL, y = NULL, force_FC) {

  cmd <- make_points_call(location = location, x = x, y = y)

	geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = TRUE)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}

make_points_call <- function(location, x, y) {
  if (!is.null(location)) {
    if (!location %in% c("centroid", "inner")) {
      stop("location must be 'centroid' or 'inner'")
    }
    if (!is.null(x) || !is.null(y)) {
      stop("You have specified both a location and x/y for point placement")
    }
    call <- list("-points", location)
  } else if (xor(is.null(x), is.null(y))) {
    stop("Only one of x/y pair found")
  } else if (!is.null(x) && !is.null(y)) {
    call <- list("-points", paste0("x=", x), paste0("y=", y))
  } else {
    stop("invalid call") ## should never get here
  }

  call

}
