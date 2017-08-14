#' Create points from a polygon layer
#'
#' Can be generated from the polygons by specifying \code{location} to be
#' \code{"centroid"} or \code{"inner"}, OR by specifying fields in the
#' attributes of the layer containing \code{x} and \code{y} coordinates.
#'
#' @param input input polygons object to convert to points. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{geo_list} polygons;
#'  \item \code{SpatialPolygons*};
#'  \item \code{sf} or \code{sfc} polygons object
#'  }
#' @param location either \code{"centroid"} or \code{"inner"}. If
#'   \code{"centroid"}, creates points at the centroid of the largest ring of
#'   each polygon feature. if \code{"inner"}, creates points in the interior of
#'   the largest ring of each polygon feature. Inner points are located away
#'   from polygon boundaries. Must be \code{NULL} if \code{x} and \code{y} are
#'   specified. If left as \code{NULL} (default), will use centroids.
#' @param x name of field containing x coordinate values. Must be \code{NULL} if
#'   \code{location} is specified.
#' @param y name of field containing y coordinate values. Must be \code{NULL} if
#'   \code{location} is specified.
#' @param force_FC should the output be forced to be a \code{FeatureCollection}
#'   even if there are no attributes? Default \code{TRUE}.
#'   \code{FeatureCollections} are more compatible with \code{rgdal::readOGR}
#'   and \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no
#'   attributes associated with the geometries, a \code{GeometryCollection} will
#'   be output. Ignored for \code{Spatial} objects, as a
#'   \code{SpatialPoints*} is always the output.
#'
#' @return points in the same class as the input.
#'
#' @examples
#' library(geojsonio)
#' library(sp)
#'
#' poly <- structure("{\"type\":\"FeatureCollection\",
#'            \"features\":[{\"type\":\"Feature\",\"properties\":
#'            {\"x_pos\": 1, \"y_pos\": 2},
#'            \"geometry\":{\"type\":\"Polygon\",
#'            \"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}},
#'            {\"type\":\"Feature\",\"properties\":{\"x_pos\": 3, \"y_pos\": 4},
#'            \"geometry\":{\"type\":\"Polygon\",
#'            \"coordinates\":[[[100,2],[98,4],[101.5,4],[100,2]]]}},
#'            {\"type\":\"Feature\",\"properties\":{\"x_pos\": 5, \"y_pos\": 6},
#'            \"geometry\":{\"type\":\"Polygon\",
#'            \"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]}}]}",
#'            class = c("json", "geo_json"))
#'
#' poly <- geojson_sp(poly)
#' summary(poly)
#' plot(poly)
#'
#' # Convert to points using centroids
#' out <- ms_points(poly, location = "centroid")
#' summary(out)
#' plot(out)
#'
#' # Can also specify locations using attributes in the data
#' out <- ms_points(poly, x = "x_pos", y = "y_pos")
#' summary(out)
#' plot(out)
#'
#' @export
ms_points <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_points")
}

#' @export
ms_points.character <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  input <- check_character_input(input)

  cmd <- make_points_call(location = location, x = x, y = y)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)

}

#' @export
ms_points.geo_json <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  cmd <- make_points_call(location = location, x = x, y = y)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)
}

#' @export
ms_points.geo_list <- function(input, location = NULL, x = NULL, y = NULL, force_FC = TRUE) {
  cmd <- make_points_call(location = location, x = x, y = y)

  geojson <- geojsonio::geojson_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @export
ms_points.SpatialPolygons <- function(input, location = NULL, x = NULL, y = NULL, force_FC) {

  cmd <- make_points_call(location = location, x = x, y = y)

  ms_sp(input, cmd)
}

#' @export
ms_points.sf <- function(input, location = NULL, x = NULL, y = NULL, force_FC) {

  cmd <- make_points_call(location = location, x = x, y = y)

  ms_sf(input, cmd)
}

#' @export
ms_points.sfc <- ms_points.sf

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
    call <- "-points"
  }

  call

}
