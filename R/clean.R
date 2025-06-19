#' Clean geometries using mapshaper
#'
#' Uses \href{https://github.com/mbloch/mapshaper}{mapshaper} to clean
#' geometries by removing overlaps, filling gaps, and repairing various kinds
#' of abnormal geometry.
#'
#' @param input spatial object to clean. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons, lines, or points;
#'  \item \code{SpatialPolygons*}, \code{SpatialLines*}, or \code{SpatialPoints*};
#'  \item \code{sf} or \code{sfc} polygons, lines, or points object
#'  }
#' @param gap_fill_area (polygons) Gaps smaller than this area will be filled;
#'   larger gaps will be retained as holes in the polygon mosaic. Numeric value
#'   in source units. Default \code{NULL} uses mapshaper's dynamic calculation.
#' @param sliver_control (polygons) Preferentially remove slivers (polygons with
#'   a high perimeter-area ratio). Accepts values from 0-1, default is 1.
#'   Multiplies the area of gap areas by the "Polsby Popper" compactness metric
#'   before applying area threshold.
#' @param overlap_rule (polygons) Assign overlapping polygon areas to one of the
#'   overlapping features based on this rule. One of: "min-id", "max-id",
#'   "min-area", "max-area". Default is "max-area".
#' @param allow_overlaps Allow features to overlap each other. The default
#'   behavior is to remove overlaps (default \code{FALSE}).
#' @param snap_interval Snap vertices within a given threshold before performing
#'   other kinds of geometry repair. Defaults to a very small threshold. Uses
#'   source units. Default \code{NULL}.
#' @param rewind Fix errors in the winding order of polygon rings (default
#'   \code{FALSE}).
#' @param allow_empty Allow null geometries, which are removed by default
#'   (default \code{FALSE}).
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet gj2008
#'
#' @details
#' Features with null geometries are deleted, unless the \code{allow_empty} flag
#' is used.
#'
#' Polygon features are cleaned by removing overlaps and filling small gaps
#' between adjacent polygons. Only gaps that are completely enclosed can be
#' filled. Areas that are contained by more than one polygon (overlaps) are
#' assigned to the polygon with the largest area by default. Similarly, gaps are
#' assigned to the largest-area polygon.
#'
#' Line features are cleaned by removing self-intersections within the same path.
#' Self-intersecting paths are split at the point of intersection and converted
#' into multiple paths within the same feature. When two separate paths intersect
#' in-between segment endpoints, new vertices are inserted at the point of
#' intersection.
#'
#' Point features are cleaned by removing duplicate coordinates within the same
#' feature.
#'
#' @return a cleaned representation of the geometry in the same class as the
#'   input
#' @examples
#' library(rmapshaper)
#' 
#' # Example with overlapping polygons
#' overlapping_poly <- structure('{
#'   "type": "FeatureCollection",
#'   "features": [
#'     {
#'       "type": "Feature",
#'       "properties": {"id": 1},
#'       "geometry": {
#'         "type": "Polygon",
#'         "coordinates": [[[0, 0], [2, 0], [2, 2], [0, 2], [0, 0]]]
#'       }
#'     },
#'     {
#'       "type": "Feature", 
#'       "properties": {"id": 2},
#'       "geometry": {
#'         "type": "Polygon",
#'         "coordinates": [[[1, 1], [3, 1], [3, 3], [1, 3], [1, 1]]]
#'       }
#'     }
#'   ]
#' }', class = c("geojson", "json"))
#' 
#' # Clean overlapping polygons
#' ms_clean(overlapping_poly)
#' 
#' # Clean with specific overlap rule
#' ms_clean(overlapping_poly, overlap_rule = "min-area")
#'
#' @export
ms_clean <- function(input, gap_fill_area = NULL, sliver_control = 1,
                     overlap_rule = "max-area", allow_overlaps = FALSE,
                     snap_interval = NULL, rewind = FALSE, allow_empty = FALSE,
                     ...) {
  UseMethod("ms_clean")
}

#' @export
ms_clean.character <- function(input, gap_fill_area = NULL, sliver_control = 1,
                               overlap_rule = "max-area", allow_overlaps = FALSE,
                               snap_interval = NULL, rewind = FALSE,
                               allow_empty = FALSE, ...) {
  input <- check_character_input(input)

  ms_clean_json(input = input, gap_fill_area = gap_fill_area,
                sliver_control = sliver_control, overlap_rule = overlap_rule,
                allow_overlaps = allow_overlaps, snap_interval = snap_interval,
                rewind = rewind, allow_empty = allow_empty, ...)
}

#' @export
ms_clean.json <- function(input, gap_fill_area = NULL, sliver_control = 1,
                          overlap_rule = "max-area", allow_overlaps = FALSE,
                          snap_interval = NULL, rewind = FALSE,
                          allow_empty = FALSE, ...) {
  ms_clean_json(input = input, gap_fill_area = gap_fill_area,
                sliver_control = sliver_control, overlap_rule = overlap_rule,
                allow_overlaps = allow_overlaps, snap_interval = snap_interval,
                rewind = rewind, allow_empty = allow_empty, ...)
}

#' @export
ms_clean.SpatialPolygons <- function(input, gap_fill_area = NULL,
                                     sliver_control = 1, overlap_rule = "max-area",
                                     allow_overlaps = FALSE, snap_interval = NULL,
                                     rewind = FALSE, allow_empty = FALSE, ...) {

  if (!is(input, "Spatial")) stop("input must be a spatial object")

  call <- make_clean_call(gap_fill_area = gap_fill_area,
                          sliver_control = sliver_control,
                          overlap_rule = overlap_rule,
                          allow_overlaps = allow_overlaps,
                          snap_interval = snap_interval,
                          rewind = rewind, allow_empty = allow_empty)

  ms_sp(input, call, ...)
}

#' @export
ms_clean.SpatialLines <- ms_clean.SpatialPolygons

#' @export
ms_clean.SpatialPoints <- ms_clean.SpatialPolygons

#' @export
ms_clean.sf <- function(input, gap_fill_area = NULL, sliver_control = 1,
                        overlap_rule = "max-area", allow_overlaps = FALSE,
                        snap_interval = NULL, rewind = FALSE, 
                        allow_empty = FALSE, ...) {

  call <- make_clean_call(gap_fill_area = gap_fill_area,
                          sliver_control = sliver_control,
                          overlap_rule = overlap_rule,
                          allow_overlaps = allow_overlaps,
                          snap_interval = snap_interval,
                          rewind = rewind, allow_empty = allow_empty)

  ms_sf(input, call, ...)
}

#' @export
ms_clean.sfc <- ms_clean.sf

ms_clean_json <- function(input, gap_fill_area, sliver_control, overlap_rule,
                          allow_overlaps, snap_interval, rewind, allow_empty, ...) {

  call <- make_clean_call(gap_fill_area = gap_fill_area,
                          sliver_control = sliver_control,
                          overlap_rule = overlap_rule,
                          allow_overlaps = allow_overlaps,
                          snap_interval = snap_interval,
                          rewind = rewind, allow_empty = allow_empty)

  ret <- apply_mapshaper_commands(data = input, command = call, ...)

  ret
}

make_clean_call <- function(gap_fill_area, sliver_control, overlap_rule,
                            allow_overlaps, snap_interval, rewind, allow_empty) {
  
  # Validate inputs
  if (!is.null(gap_fill_area) && (!is.numeric(gap_fill_area) || gap_fill_area < 0)) {
    stop("gap_fill_area must be a positive numeric value or NULL")
  }
  
  if (!is.numeric(sliver_control) || sliver_control < 0 || sliver_control > 1) {
    stop("sliver_control must be a numeric value between 0 and 1")
  }
  
  valid_overlap_rules <- c("min-id", "max-id", "min-area", "max-area")
  if (!overlap_rule %in% valid_overlap_rules) {
    stop("overlap_rule must be one of: ", paste(valid_overlap_rules, collapse = ", "))
  }
  
  if (!is.null(snap_interval) && (!is.numeric(snap_interval) || snap_interval < 0)) {
    stop("snap_interval must be a positive numeric value or NULL")
  }
  
  # Build command arguments
  args <- "-clean"
  
  if (!is.null(gap_fill_area)) {
    args <- c(args, paste0("gap-fill-area=", format(gap_fill_area, scientific = FALSE)))
  }
  
  if (sliver_control != 1) {
    args <- c(args, paste0("sliver-control=", format(sliver_control, scientific = FALSE)))
  }
  
  if (overlap_rule != "max-area") {
    args <- c(args, paste0("overlap-rule=", overlap_rule))
  }
  
  if (allow_overlaps) {
    args <- c(args, "allow-overlaps")
  }
  
  if (!is.null(snap_interval)) {
    args <- c(args, paste0("snap-interval=", format(snap_interval, scientific = FALSE)))
  }
  
  if (rewind) {
    args <- c(args, "rewind")
  }
  
  if (allow_empty) {
    args <- c(args, "allow-empty")
  }
  
  as.list(args)
}
