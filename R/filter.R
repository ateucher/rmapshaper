#' Filter features based on attributes
#'
#' Apply a boolean expression to the attributes of each feature, removeing those
#' which evaluate to \code{FALSE}
#'
#' @param input spatial object to filter - can be one of the \code{Spatial}
#'   classes (e.g., \code{SpatialPolygonsDataFrame}) or class \code{geo_json}
#' @param filter expression to apply. Can be a character vector of individual
#'   conditional statements, which will be combined with logical \code{AND (&)},
#'   or a single string combining expressions with \code{&} and/or \code{|}. You
#'   can use javascript syntax if you are familiar with it, or R syntax which
#'   will be converted to javascript internally.
#' @param drop_null_geometries should features with empty geometries be dropped? Default \code{TRUE}
#' @param force_FC should the output be forced to be a \code{FeatureCollection}
#'   even if there are no attributes? Default \code{TRUE}.
#'   \code{FeatureCollections} are more compatible with \code{rgdal::readOGR}
#'   and \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no
#'   attributes associated with the geometries, a \code{GeometryCollection} will
#'   be output. Ignored for \code{Spatial} objects, as a
#'   \code{Spatial*DataFrame} is always the output.
#'
#' @return object with only specified features retained, in the same class as
#'   the input
#' @export
ms_filter <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_filter")
}

#' @describeIn ms_filter For character representations of geojson (for example
#' if you used \code{readLines} to read in a geojson file)
#' @export
ms_filter.character <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC = TRUE) {
  input <- check_character_input(input)

  cmd <- make_filter_call(filter, drop_null_geometries)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)

}

#' @describeIn ms_filter Method for geo_json
#' @export
ms_filter.geo_json <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC = TRUE) {
  cmd <- make_filter_call(filter, drop_null_geometries)

  apply_mapshaper_commands(data = input, command = cmd, force_FC = force_FC)
}

#' @describeIn ms_filter Method for geo_list
#' @export
ms_filter.geo_list <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  cmd <- make_filter_call(filter, drop_null_geometries)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

#' @describeIn ms_filter Method for SpatialPolygonsDataFrame
#' @export
ms_filter.SpatialPolygonsDataFrame <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC) {
  ms_filter_sp(input = input, filter = filter, force_FC = force_FC)
}

#' @describeIn ms_filter Method for SpatialLinesDataFrame
#' @export
ms_filter.SpatialLinesDataFrame <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC) {
  ms_filter_sp(input = input, filter = filter, force_FC = force_FC)
}

#' @describeIn ms_filter Method for SpatialPointsDataFrame
#' @export
ms_filter.SpatialPointsDataFrame <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC) {
  ms_filter_sp(input = input, filter = filter, force_FC = force_FC)
}

ms_filter_sp <- function(input, filter = NULL, drop_null_geometries = TRUE, force_FC) {

  cmd <- make_filter_call(filter, drop_null_geometries)

  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(data = geojson, command = cmd, force_FC = TRUE)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}

make_filter_call <- function(filter, drop_null_geometries) {
  # comparisons: ==, >, >=, <, <=, !
  # http://www.w3schools.com/js/js_comparisons.asp
  # types: is.na, is.numeric, is.integer, is.character - use typeof in javascript
  # http://javascript.info/tutorial/type-detection

  if (drop_null_geometries) rem <- "remove-empty" else rem <- NULL

  filter <- make_js_expression(filter)

  call <- list("-filter", rem, paste0("'", filter, "'"))
  call
}

make_js_expression <- function(x) {
  ## Convert is.na to === null
  x <- switch_na_test(x)

  ## Convert R-style single &,| to js-style &&,|| and ==/!= to ===/!==
  x <- convert_logical(x)

  ## If more than one conditional statement, combine with &&
  if (length(x) > 1) {
    x <- paste0("(", x, ")")
    x <- paste0(x, collapse = " && ")
  }

  message("JavaScript expression evaluated: '", x, "'")

  x
}

switch_na_test <- function(x) {
  na_search_str <- "(!)?is\\.na"
  repl_str <- "\\1=== null"

  na_calls <- vapply(x, function(y) grepl(na_search_str, y), logical(1))

  x[na_calls] <- vapply(x[na_calls], function(y) {
    searchstr <- paste0(na_search_str, "\\(([^)\r\n]+)\\)") ## Regex matches everything inside () except ) and line endings
    gsub(searchstr, paste("\\2", repl_str, sep = " "), y)
  }, character(1))

  x
}

convert_logical <- function(x) {
  x <- gsub("\\&+", "&&", x)
  x <- gsub("\\|+", "||", x)
  x <- gsub("==+", "===", x)
  x <- gsub("!=+", "!==", x)
  x <- gsub("\\bTRUE\\b", "true", x)
  x <- gsub("\\bFALSE\\b", "false", x)
  x
}

# switch_type_test <- function(x) {
#   type_lookup <- data.frame(
#     r_fn_re = c("(!)?is\\.na", "(!)?is\\.numeric", "(!)?is\\.character", "(!)?is\\.logical"),
#     js_type = c("\\1=== null", "\\1=== 'number'", "\\1=== 'string'", "\\1=== 'boolean'"),
#     js_fn_re = c("\\2", rep("typeof(\\2)", 3)),
#     stringsAsFactors = FALSE
#   )
#
#   # Make a list of logical vectors for whether or not the R function shows up in that element of x
#   types_rows <- lapply(x, function(y) {
#     vapply(type_lookup$r_fn_re, function(re) grepl(re, y), logical(1))
#   })
#
#   ret <- x
#   for (i in seq_along(ret)) {
#     types <- type_lookup[types_rows[[i]], ]
#     if (nrow(types) > 0) {
#       for (t in 1:nrow(types)) {
#         searchstr <- paste0(types[t,"r_fn_re"], "\\(([^)\r\n]+)\\)") ## Regex matches everything inside () except ) and line endings
#         ret[i] <- gsub(searchstr,
#                        paste(types[t,"js_fn_re"], types[t, "js_type"], sep = " "),
#                        ret[i])
#       }
#     }
#   }
#   ret
# }
