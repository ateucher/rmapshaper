#' Topologically-aware geometry simplification.
#'
#' Uses \href{https://github.com/mbloch/mapshaper}{mapshaper} to simplify
#' polygons.
#'
#' @param sp_obj spatial object to simplify - can be one of the Spatial classes (e.g., SpatialPolygonsDataFrame) or class json
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
#'
#' @return a simplified representation of the geometry in the same class as the input
#' @export
simplify <- function(sp_obj, keep = 0.05, method = NULL, keep_shapes = TRUE,
                     no_repair = FALSE, snap = TRUE) {
  UseMethod("simplify")
}

#' @export
simplify.SpatialPolygonsDataFrame <- function(sp_obj, keep = 0.05, method = NULL,
                                             keep_shapes = TRUE, no_repair = FALSE,
                                             snap = TRUE) {

  if (!is(sp_obj, "Spatial")) stop("sp_obj must be a spatial object")

  call <- make_simplify_call(keep = keep, method = method,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap)

  geojson <- sp_to_GeoJSON(sp_obj)

  ret <- apply_mapshaper_commands(call, geojson)

  GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))
}

#' @importFrom geojsonio lint
#' @export
simplify.json <- function(sp_obj, keep = 0.05, method = NULL, keep_shapes = TRUE,
                          no_repair = FALSE, snap = TRUE) {
  if (geojsonio::lint(sp_obj) != "valid") stop("Not a valid geojson object!")

  call <- make_simplify_call(keep = keep, method = method,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap)

  ret <- apply_mapshaper_commands(call, sp_obj)

  structure(ret, class = "json")
}

make_simplify_call <- function(keep, method, keep_shapes, no_repair, snap) {
  if (keep > 1 || keep < 0) stop("keep must be in the range 0-1")

  if (is.null(method)) {
    method <- ""
  } else if (method == "vis") {
    method <- "visvalingam"
  } else if (!method == "dp") {
    stop("method should be one of 'vis', 'dp', or NULL (to use the default weighted Visvalingam method)")
  }

  if (keep_shapes) keep_shapes <- "keep-shapes" else keep_shapes <- ""

  if (no_repair) no_repair <- "no-repair" else no_repair <- ""

  if (snap) snap <- "snap" else snap <- ""

  call <- sprintf("%s -simplify %s %s %s %s", snap, keep, method, keep_shapes,
                  no_repair)

  call <- gsub("\\s+", " ", call)
  call
}

