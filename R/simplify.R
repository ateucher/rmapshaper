#' Topologically-aware simplification of spatial objects.
#'
#' Uses \href{https://github.com/mbloch/mapshaper}{mapshaper} to simplify
#' polygons.
#'
#' @importFrom geojsonio geojson_json
#'
#' @param sp_obj spatial object to simplify
#' @param keep proportion of points to retain (0-1; default 0.05)
#' @param method simplification method to use: \code{"vis"} for Visvalingam
#'   algorithm (default), or \code{"dp"} for Douglas-Peuker algorithm. See this
#'   \url{https://github.com/mbloch/mapshaper/wiki/Simplification-Tips}{link}
#'   for more information.
#' @param keep_shapes Prevent polygon features from disappearing at high
#'   simplification (default \code{TRUE})
#' @param no_repair disable intersection repair after simplification (default
#'   \code{FALSE}).
#' @param auto_snap Snap together vertices within a small distance threshold to
#'   fix small coordinate misalignment in adjacent polygons. Default
#'   \code{TRUE}. (currently not supported)
#'
#' @return an \code{sp} object
#' @export
simplify <- function(sp_obj, keep = 0.05, method = "vis", keep_shapes = TRUE,
                     no_repair = FALSE, auto_snap = TRUE) {

  # if (!is(sp_obj, "Spatial")) stop("sp_obj must be a spatial object")
  if (keep > 1 || keep < 0) stop("keep must be in the range 0-1")

  if (method == "vis") {
    method <- "visvalingam"
  } else if (!(method == "dp")) {
    stop("method should be one of 'vis' or 'dp'")
  }

  if (keep_shapes) keep_shapes <- "keep-shapes" else keep_shapes <- ""

  if (no_repair) no_repair <- "no-repair" else no_repair <- ""

  # if (auto_snap) auto_snap <- "auto-snap" else auto_snap <- ""

  call <- sprintf("-simplify %s %s %s %s", keep, method, keep_shapes, no_repair)
  call <- gsub("\\s+", " ", call)

  ret <- run_mapshaper_command(sp_obj, call)

  ret

}

