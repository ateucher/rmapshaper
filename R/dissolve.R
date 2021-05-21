#' Aggregate shapes in a polygon or point layer.
#'
#' Aggregates using specified field, or all shapes if no field is given. For point layers,
#' replaces a group of points with their centroid.
#'
#' @param input spatial object to dissolve. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} points or polygons;
#'  \item \code{geo_list} points or polygons;
#'  \item \code{SpatialPolygons}, or \code{SpatialPoints}
#'  }
#' @param snap Snap together vertices within a small distance threshold to fix
#'   small coordinate misalignment in adjacent polygons. Default \code{TRUE}.
#' @param field the field to dissolve on
#' @param sum_fields fields to sum
#' @param copy_fields fields to copy. The first instance of each field will be
#'   copied to the aggregated feature.
#' @param weight Name of an attribute field for generating weighted centroids (points only).
#' @inheritParams apply_mapshaper_commands
#'
#' @return the same class as the input
#'
#' @examples
#' library(geojsonio)
#' library(sp)
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
#'   ]]}}]}', class = c("json", "geo_json"))
#' poly <- geojson_sp(poly)
#' plot(poly)
#' length(poly)
#' poly@data
#'
#' # Dissolve the polygon
#' out <- ms_dissolve(poly)
#' plot(out)
#' length(out)
#' out@data
#'
#' # Dissolve and summing columns
#' out <- ms_dissolve(poly, sum_fields = c("a", "b"))
#' plot(out)
#' out@data
#'
#' @export
ms_dissolve <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                        weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {
  UseMethod("ms_dissolve")
}

#' @export
ms_dissolve.character <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                  weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {
  input <- check_character_input(input)

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, weight = weight,
                             copy_fields = copy_fields, snap = snap)

  apply_mapshaper_commands(data = input, command = call, force_FC = force_FC, sys = sys, sys_mem = sys_mem)

}

#' @export
ms_dissolve.geo_json <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                 weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, weight = weight,
                             copy_fields = copy_fields, snap = snap)

  apply_mapshaper_commands(data = input, command = call, force_FC = force_FC, sys = sys, sys_mem = sys_mem)
}

#' @export
ms_dissolve.geo_list <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                 weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, weight = weight,
                             copy_fields = copy_fields, snap = snap)

  geojson <- geo_list_to_json(input)

  ret <- apply_mapshaper_commands(data = geojson, command = call, force_FC = force_FC, sys = sys, sys_mem = sys_mem)

  geojsonio::geojson_list(ret)
}

#' @export
ms_dissolve.SpatialPolygons <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                        weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {
 dissolve_sp(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
             weight = weight, snap = snap, sys = sys, sys_mem = sys_mem)
}

#' @export
ms_dissolve.SpatialPoints <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                                      weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {
  dissolve_sp(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
              weight = weight, snap = snap, sys = sys, sys_mem = sys_mem)
}

#' @export
ms_dissolve.sf <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                           weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {
  if (!is.null(weight) && !(weight %in% names(input))) {
    stop("specified 'weight' column not present in input data", call. = FALSE)
  }

  dissolve_sf(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
              weight = weight, snap = snap, sys = sys, sys_mem = sys_mem)

}

#' @export
ms_dissolve.sfc <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL,
                            weight = NULL, snap = TRUE, force_FC = TRUE, sys = FALSE, sys_mem = 8) {
  if (!is.null(weight)) {
    warning("'weight' cannot be used with sfc objects. Ignoring it and proceeding...")
  }

  dissolve_sf(input = input, field = field, sum_fields = sum_fields, copy_fields = copy_fields,
              weight = NULL, snap = snap, sys = sys, sys_mem = sys_mem)
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

dissolve_sp <- function(input, field, sum_fields, copy_fields, weight, snap, sys, sys_mem) {

  if (!inherits(input, "SpatialPointsDataFrame") && !is.null(weight)) {
    stop("weight arguments only applies to points with attributes", call. = FALSE)
  }

  if (!is.null(weight) && !(weight %in% names(input))) {
    stop("specified 'weight' column not present in input data", call. = FALSE)
  }

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, copy_fields = copy_fields,
                             weight = weight, snap = snap)

  ms_sp(input = input, call = call, sys = sys, sys_mem = sys_mem)
}

dissolve_sf <- function(input, field, sum_fields, copy_fields, weight, snap, sys, sys_mem) {

  if (!all(sf::st_is(input, c("POINT", "MULTIPOINT", "POLYGON", "MULTIPOLYGON")))) {
    stop("ms_dissolve only works with (MULTI)POINT or (MULTI)POLYGON", call. = FALSE)
  }

  if (!all(sf::st_is(input, c("POINT", "MULTIPOINT"))) && !is.null(weight)) {
    stop("weights arguments only applies to points", call. = FALSE)
  }

  call <- make_dissolve_call(field = field, sum_fields = sum_fields, copy_fields = copy_fields,
                             weight = weight, snap = snap)

  ms_sf(input = input, call = call, sys = sys, sys_mem = sys_mem)
}
