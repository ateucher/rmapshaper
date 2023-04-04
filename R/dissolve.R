#' Aggregate shapes in a polygon or point layer.
#'
#' Aggregates using specified field, or all shapes if no field is given. For point layers,
#' replaces a group of points with their centroid.
#'
#' @param input spatial object to dissolve. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} points or polygons;
#'  \item \code{SpatialPolygons}, or \code{SpatialPoints}
#'  }
#' @param snap Snap together vertices within a small distance threshold to fix
#'   small coordinate misalignment in adjacent polygons. Default \code{TRUE}.
#' @param field the field to dissolve on
#' @param sum_fields fields to sum
#' @param copy_fields fields to copy. The first instance of each field will be
#'   copied to the aggregated feature.
#' @param weight Name of an attribute field for generating weighted centroids (points only).
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet
#'
#' @return the same class as the input
#'
#' @examples
#' library(geojsonsf)
#' library(sf)
#'
#' poly <- structure('{"type":"FeatureCollection",
#'   "features":[
#'   {"type":"Feature",
#'   "properties":{"a": 1, "b": 2},
#'   "geometry":{"type":"Polygon","coordinates":[[
#'   [102,2],[102,3],[103,3],[103,2],[102,2]
#'   ]]}}
#'   ,{"type":"Feature",
#'   "properties":{"a": 5, "b": 3},
#'   "geometry":{"type":"Polygon","coordinates":[[
#'   [100,0],[100,1],[101,1],[101,0],[100,0]
#'   ]]}}]}', class = c("geojson", "json"))
#' poly <- geojson_sf(poly)
#' plot(poly)
#' length(poly)
#' poly
#'
#' # Dissolve the polygon
#' out <- ms_dissolve(poly)
#' plot(out)
#' length(out)
#' out
#'
#' # Dissolve and summing columns
#' out <- ms_dissolve(poly, sum_fields = c("a", "b"))
#' plot(out)
#' out
#'
#' @export
ms_dissolve <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                        weight = NULL, snap = TRUE, ...) {
  UseMethod("ms_dissolve")
}

#' @export
ms_dissolve.character <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                  weight = NULL, snap = TRUE, ...) {
  input <- check_character_input(input)

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, weight = weight,
                             copy_fields = copy_fields, snap = snap)

  apply_mapshaper_commands(data = input, command = call, ...)

}

#' @export
ms_dissolve.json <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                 weight = NULL, snap = TRUE, ...) {
  call <- make_dissolve_call(field = field, sum_fields = sum_fields, weight = weight,
                             copy_fields = copy_fields, snap = snap)

  apply_mapshaper_commands(data = input, command = call, ...)
}

#' @export
ms_dissolve.SpatialPolygons <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                        weight = NULL, snap = TRUE, ...) {
 dissolve_sp(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
             weight = weight, snap = snap, ...)
}

#' @export
ms_dissolve.SpatialPoints <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                      weight = NULL, snap = TRUE, ...) {
  dissolve_sp(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
              weight = weight, snap = snap, ...)
}

#' @export
ms_dissolve.sf <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                           weight = NULL, snap = TRUE, ...) {
  if (!is.null(weight) && !(weight %in% names(input))) {
    stop("specified 'weight' column not present in input data", call. = FALSE)
  }

  dissolve_sf(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
              weight = weight, snap = snap, ...)

}

#' @export
ms_dissolve.sfc <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                            weight = NULL, snap = TRUE, ...) {
  if (!is.null(weight)) {
    warning("'weight' cannot be used with sfc objects. Ignoring it and proceeding...")
  }

  dissolve_sf(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
              weight = NULL, snap = snap, ...)
}

make_dissolve_call <- function(field, sum_fields, copy_fields, weight, snap) {

  if (is.null(sum_fields)) {
    sum_fields_string <- NULL
  } else {
    sum_fields_string <- paste0("sum-fields=", paste0(sum_fields, collapse = ","))
  }

  if (is.null(copy_fields)) {
    copy_fields_string <- NULL
  } else {
    copy_fields_string <- paste0("copy-fields=", paste0(copy_fields, collapse = ","))
  }

  if (is.null(weight)) {
    weight_string <- NULL
  } else {
    weight_string <- paste0("weight=", weight)
  }

  if (snap) snap <- "snap" else snap <- NULL

  call <- list(snap, "-dissolve", field, sum_fields_string, copy_fields_string, weight_string)

  call
}

dissolve_sp <- function(input, field, sum_fields, copy_fields, weight, snap, ...) {

  if (!inherits(input, "SpatialPointsDataFrame") && !is.null(weight)) {
    stop("weight arguments only applies to points with attributes", call. = FALSE)
  }

  if (!is.null(weight) && !(weight %in% names(input))) {
    stop("specified 'weight' column not present in input data", call. = FALSE)
  }

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, copy_fields = copy_fields,
                             weight = weight, snap = snap)

  ms_sp(input = input, call = call, ...)
}

dissolve_sf <- function(input, field, sum_fields, copy_fields, weight, snap, ...) {

  if (!all(sf::st_is(input, c("POINT", "MULTIPOINT", "POLYGON", "MULTIPOLYGON")))) {
    stop("ms_dissolve only works with (MULTI)POINT or (MULTI)POLYGON", call. = FALSE)
  }

  if (!all(sf::st_is(input, c("POINT", "MULTIPOINT"))) && !is.null(weight)) {
    stop("weights arguments only applies to points", call. = FALSE)
  }

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, copy_fields = copy_fields,
                             weight = weight, snap = snap)

  ms_sf(input = input, call = call, ...)
}
