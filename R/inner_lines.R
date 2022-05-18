#' Create a line layer consisting of shared boundaries with no attribute data
#'
#' @param input input polygons object to convert to inner lines. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{SpatialPolygons*};
#'  \item \code{sf} or \code{sfc} polygons object
#'  }
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet
#'
#' @return lines in the same class as the input layer, but without attributes
#'
#' @examples
#' library(geojsonsf)
#' library(sf)
#'
#' poly <- structure('{"type":"FeatureCollection",
#'             "features":[
#'               {"type":"Feature",
#'                 "properties":{"foo": "a"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [102,2],[102,3],[103,3],[103,2],[102,2]
#'                   ]]}}
#'               ,{"type":"Feature",
#'                 "properties":{"foo": "a"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [103,3],[104,3],[104,2],[103,2],[103,3]
#'                   ]]}},
#'               {"type":"Feature",
#'                 "properties":{"foo": "b"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [102,1],[102,2],[103,2],[103,1],[102,1]
#'                   ]]}},
#'               {"type":"Feature",
#'                 "properties":{"foo": "b"},
#'                 "geometry":{"type":"Polygon","coordinates":[[
#'                   [103,1],[103,2],[104,2],[104,1],[103,1]
#'                   ]]}}]}', class = c("geojson", "json"))
#'
#' poly <- geojson_sf(poly)
#' plot(poly)
#'
#' out <- ms_innerlines(poly)
#' plot(out)
#'
#' @export
ms_innerlines <- function(input, ...) {
  UseMethod("ms_innerlines")
}

#' @export
ms_innerlines.character <- function(input, ...) {
  input <- check_character_input(input)

  apply_mapshaper_commands(data = input, command = "-innerlines", ...)

}

#' @export
ms_innerlines.json <- function(input, ...) {
  apply_mapshaper_commands(data = input, command = "-innerlines", ...)
}

#' @export
ms_innerlines.SpatialPolygons <- function(input, ...) {
	ms_sp(as(input, "SpatialPolygons"), "-innerlines", ...)
}

#' @export
ms_innerlines.sf <- function(input, ...) {
  ms_sf(sf::st_geometry(input), "-innerlines", ...)
}


#' @export
ms_innerlines.sfc <- function(input, ...) {
  ms_sf(input, "-innerlines", ...)
}

