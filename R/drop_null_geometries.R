#' Drop features from a \code{geo_json} FeatureCollection with null geometries
#'
#' @param x a \code{geo_json} FeatureCollection
#'
#' @return a \code{geo_json} FeatureCollection with Features with null geometries
#' removed
#' @export
drop_null_geometries <- function(x) {
  UseMethod("drop_null_geometries")
}

#' @export
drop_null_geometries.json <- function(x) {
  apply_mapshaper_commands(x, "-filter remove-empty", TRUE)
}

#' @export
drop_null_geometries.character <- drop_null_geometries.json
