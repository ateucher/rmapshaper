#' Aggregate shapes in a polygon layer.
#'
#' Aggregates using specified field, or all shapes if no field is given
#'
#' @param sp_obj spatial object to dissolve - can be one of the Spatial classes (e.g., SpatialPolygonsDataFrame) or class json
#' @param snap Snap together vertices within a small distance threshold to
#'   fix small coordinate misalignment in adjacent polygons. Default
#'   \code{TRUE}.
#' @param field the field to dissolve on
#' @param sum_fields
#' @param copy_fields
#'
#' @return a simplified representation of the geometry in the same class as the input
#' @export
dissolve <- function(sp_obj, field = NULL, sum_fields = NULL, copy_fields = NULL, snap = TRUE) {
  UseMethod("dissolve")
}

#' @export
dissolve.SpatialPolygonsDataFrame <- function(sp_obj, field = NULL, sum_fields = NULL, copy_fields = NULL, snap = TRUE) {

  if (!is(sp_obj, "Spatial")) stop("sp_obj must be a spatial object")

  call <- make_dissolve_call(field = field, sum_fields = sum_fields,
                             copy_fields = copy_fields, snap = snap)

  geojson <- sp_to_GeoJSON(sp_obj)

  ret <- apply_mapshaper_commands(call, geojson)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4")) ## This fails if field == NULL
}

#' @export
dissolve.json <- function(sp_obj, field = NULL, sum_fields = NULL, copy_fields = NULL, snap = TRUE) {

  call <- make_dissolve_call(field = field, sum_fields = sum_fields,
                             copy_fields = copy_fields, snap = snap)

  ret <- apply_mapshaper_commands(call, sp_obj)

  structure(ret, class = "json")
}

make_dissolve_call <- function(field, sum_fields, copy_fields, snap) {

  if (is.null(field)) field <- ""

  if (is.null(sum_fields)) {
    sum_fields_call <- ""
  } else {
    sum_fields_call <- paste0("sum-fields=", paste0(sum_fields, collapse = ","))
  }

  if (is.null(copy_fields)) {
    copy_fields_call <- ""
  } else {
    copy_fields_call <- paste0("copy-fields=", paste0(copy_fields, collapse = ","))
  }

  if (snap) if (snap) snap <- "snap" else snap <- ""

  call <- sprintf("%s -dissolve %s %s %s", snap, field, sum_fields_call,
                  copy_fields_call)

  call <- gsub("\\s+", " ", call)
  call
}