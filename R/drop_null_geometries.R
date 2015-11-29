#' Drop features from a \code{geo_list} or \code{geo_json} FeatureCollection with null geometries
#'
#' @param x a \code{geo_list} or \code{geo_json} FeatureCollection
#'
#' @return a \code{geo_list} or \code{geo_json} FeatureCollection with Features with null geometries
#' removed
#' @export
drop_null_geometries <- function(x) {
  UseMethod("drop_null_geometries")
}

#' @export
drop_null_geometries.geo_json <- function(x) {
  apply_mapshaper_commands(x, "-filter remove-empty", TRUE)
}

#' @export
drop_null_geometries.geo_list <- function(x) {
  # Using -filter mapshaper command
  geojson <- geojsonio::geojson_json(x)
  ret <- drop_null_geometries.geo_json(geojson)
  geojsonio::geojson_list(ret)

  ## Use the list directly - it's faster
  # drop_null_geometries_list(x)
}

# drop_null_geometries_list <- function(x) {
#   if (x$type != "FeatureCollection") {
#     stop("type must be a FeatureCollection")
#   }
#
#   features_to_keep <- vapply(x$features,
#                              function(y) !is.null(y$geometry),
#                              logical(1))
#   x$features <- x$features[features_to_keep]
#   x
# }