#' Drop features from a geo_list FeatureCollection with null geometries
#'
#' @param x a geo_list FeatureCollection
#'
#' @return a geo_list FeatureCollection with Features with null geometries
#' removed
#' @export
drop_null_geometries <- function(x) {
  UseMethod("drop_null_geometries")
}

#' @export
drop_null_geometries.geo_json <- function(x) {
  list <- geojsonio::geojson_list(x)
  ret <- drop_null_geometries_list(list)
  geojsonio::geojson_json(ret)
}

#' @export
drop_null_geometries.geo_list <- function(x) {
  drop_null_geometries_list(x)
}

drop_null_geometries_list <- function(x) {

  if (!x$type == "FeatureCollection") {
    stop("type must be a FeatureCollection")
  }

  features_to_keep <- vapply(x$features,
                             function(y) !is.null(y$geometry),
                             logical(1))
  x$features <- x$features[features_to_keep]
  x
}