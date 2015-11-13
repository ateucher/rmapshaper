#' Aggregate shapes in a polygon layer.
#'
#' Aggregates using specified field, or all shapes if no field is given
#'
#' @param input spatial object to dissolve - can be one of the Spatial classes (e.g., SpatialPolygonsDataFrame) or class json
#' @param snap Snap together vertices within a small distance threshold to
#'   fix small coordinate misalignment in adjacent polygons. Default
#'   \code{TRUE}.
#' @param field the field to dissolve on
#' @param sum_fields fields to sum
#' @param copy_fields fields to copy. The first instance of each field will be copied to the aggregated feature.
#'
#' @return the same class as the input
#' @export
ms_dissolve <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL, snap = TRUE) {
  UseMethod("ms_dissolve")
}

#' @export
ms_dissolve.SpatialPolygonsDataFrame <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL, snap = TRUE) {

  if (!is(input, "Spatial")) stop("input must be a spatial object")

  call <- make_dissolve_call(field = field, sum_fields = sum_fields,
                             copy_fields = copy_fields, snap = snap)

  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(call, geojson)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4")) ## This fails if field == NULL. See http://stackoverflow.com/questions/30583048/convert-features-of-a-multifeature-geojson-into-r-spatial-objects
}

#' @export
ms_dissolve.json <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL, snap = TRUE) {

  call <- make_dissolve_call(field = field, sum_fields = sum_fields,
                             copy_fields = copy_fields, snap = snap)

  apply_mapshaper_commands(call, input)
}

#' @importFrom geojsonio geojson_json
#' @export
ms_dissolve.geo_list <- function(input, field = NULL, sum_fields = NULL, copy_fields = NULL, snap = TRUE) {

  call <- make_dissolve_call(field = field, sum_fields = sum_fields,
                             copy_fields = copy_fields, snap = snap)

  geojson <- geojson_json(input)

  ret <- apply_mapshaper_commands(call, geojson)

  geojson_to_geo_list(ret)
}


make_dissolve_call <- function(field, sum_fields, copy_fields, snap) {

  if (is.null(field)) field <- ""

  if (is.null(sum_fields)) {
    sum_fields_string <- ""
  } else {
    sum_fields_string <- paste0("sum-fields=", paste0(sum_fields, collapse = ","))
  }

  if (is.null(copy_fields)) {
    copy_fields_string <- ""
  } else {
    copy_fields_string <- paste0("copy-fields=", paste0(copy_fields, collapse = ","))
  }

  if (snap) snap <- "snap" else snap <- ""

  call <- sprintf("%s -dissolve %s %s %s", snap, field, sum_fields_string,
                  copy_fields_string)

  call <- gsub("\\s{2,}", " ", call)
  call
}