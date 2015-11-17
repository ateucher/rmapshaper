#' Topologically-aware geometry simplification.
#'
#' Uses \href{https://github.com/mbloch/mapshaper}{mapshaper} to simplify
#' polygons.
#'
#' @param input spatial object to simplify - can be one of the Spatial classes (e.g., SpatialPolygonsDataFrame) or class geo_json
#' @param keep proportion of points to retain (0-1; default 0.05)
#' @param method simplification method to use: \code{"vis"} for Visvalingam
#'   algorithm, or \code{"dp"} for Douglas-Peuker algorithm. If left as
#'   \code{NULL} (default), uses Visvalingam simplification but modifies the
#'   area metric by underweighting the effective area of points at the vertex of
#'   more acute angles, resulting in a smoother appearance. See this
#'   \url{https://github.com/mbloch/mapshaper/wiki/Simplification-Tips}{link}
#'   for more information.
#' @param keep_shapes Prevent polygon features from disappearing at high
#'   simplification (default \code{TRUE})
#' @param no_repair disable intersection repair after simplification (default
#'   \code{FALSE}).
#' @param snap Snap together vertices within a small distance threshold to
#'   fix small coordinate misalignment in adjacent polygons. Default
#'   \code{TRUE}.
#' @param explode Should multipart polygons be converted to singlepart polygons?
#'    This prevents small shapes from disappearing during simplification.
#'    Default \code{FALSE}
#' @param force_FC should the output be forced to be a FeatureCollection (or
#'  Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'  the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'  will be output.
#'
#' @return a simplified representation of the geometry in the same class as the input
#' @examples
#' # With a simple geojson object
#' poly <- structure('{
#'   "type": "Feature",
#'   "properties": {},
#'   "geometry": {
#'     "type": "Polygon",
#'     "coordinates": [[
#'       [-70.603637, -33.399918],
#'       [-70.614624, -33.395332],
#'       [-70.639343, -33.392466],
#'       [-70.659942, -33.394759],
#'       [-70.683975, -33.404504],
#'       [-70.697021, -33.419406],
#'       [-70.701141, -33.434306],
#'       [-70.700454, -33.446339],
#'       [-70.694274, -33.458369],
#'       [-70.682601, -33.465816],
#'       [-70.668869, -33.472117],
#'       [-70.646209, -33.473835],
#'       [-70.624923, -33.472117],
#'       [-70.609817, -33.468107],
#'       [-70.595397, -33.458369],
#'       [-70.587158, -33.442901],
#'       [-70.587158, -33.426283],
#'       [-70.590591, -33.414248],
#'       [-70.594711, -33.406224],
#'       [-70.603637, -33.399918]
#'     ]]
#'   }
#' }', class = c("json", "geo_json"))
#'
#' ms_simplify(poly)
#'
#' \dontrun{
#' # With a SpatialPolygonsDataFrame. You will need the rworldmap package for this example:
#' library("rworldmap")
#' world <- getMap()
#' ms_simplify(world)
#' }
#'
#' @export
ms_simplify <- function(input, keep = 0.05, method = NULL, keep_shapes = TRUE,
                        no_repair = FALSE, snap = TRUE, explode = FALSE, force_FC = TRUE) {
  UseMethod("ms_simplify")
}

#' @export
ms_simplify.SpatialPolygonsDataFrame <- function(input, keep = 0.05, method = NULL,
                                                 keep_shapes = TRUE, no_repair = FALSE,
                                                 snap = TRUE, explode = FALSE, force_FC = TRUE) {

  if (!is(input, "Spatial")) stop("input must be a spatial object")

  call <- make_simplify_call(keep = keep, method = method,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap, explode = explode)

  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(call, geojson, force_FC = force_FC)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}

#' @export
ms_simplify.geo_json <- function(input, keep = 0.05, method = NULL, keep_shapes = TRUE,
                             no_repair = FALSE, snap = TRUE, explode = FALSE, force_FC = TRUE) {

  call <- make_simplify_call(keep = keep, method = method,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap, explode = explode)

  apply_mapshaper_commands(call, input, force_FC = force_FC)
}

#' @importFrom geojsonio geojson_list
#' @export
ms_simplify.geo_list <- function(input, keep = 0.05, method = NULL, keep_shapes = TRUE,
                                 no_repair = FALSE, snap = TRUE, explode = FALSE, force_FC = TRUE) {
  geojson <- geojsonio::geojson_json(input)

  call <- make_simplify_call(keep = keep, method = method,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap, explode = explode)

  ret <- apply_mapshaper_commands(call, geojson, force_FC = force_FC)

  geojsonio::geojson_list(ret)
}

make_simplify_call <- function(keep, method, keep_shapes, no_repair, snap, explode) {
  if (keep > 1 || keep < 0) stop("keep must be in the range 0-1")

  if (is.null(method)) {
    method <- ""
  } else if (method == "vis") {
    method <- "visvalingam"
  } else if (!method == "dp") {
    stop("method should be one of 'vis', 'dp', or NULL (to use the default weighted Visvalingam method)")
  }

  if (explode) explode <- "-explode" else explode <- NULL
  if (snap) snap <- "snap" else snap <- NULL
  if (keep_shapes) keep_shapes <- "keep-shapes" else keep_shapes <- NULL
  if (no_repair) no_repair <- "no-repair" else no_repair <- NULL

  call <- list(explode, snap, "-simplify", keep, method,
                  keep_shapes, no_repair)

  call
}

