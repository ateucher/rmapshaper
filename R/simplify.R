#' Topologically-aware geometry simplification.
#'
#' Uses \href{https://github.com/mbloch/mapshaper}{mapshaper} to simplify
#' polygons.
#'
#' @param input spatial object to simplify. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons or lines;
#'  \item \code{geo_list} polygons or lines;
#'  \item \code{SpatialPolygons*} or \code{SpatialLines*};
#'  \item \code{sf} or \code{sfc} polygons or lines object
#'  }
#' @param keep proportion of points to retain (0-1; default 0.05)
#' @param method simplification method to use: \code{"vis"} for Visvalingam
#'   algorithm, or \code{"dp"} for Douglas-Peuker algorithm. If left as
#'   \code{NULL} (default), uses Visvalingam simplification but modifies the
#'   area metric by underweighting the effective area of points at the vertex of
#'   more acute angles, resulting in a smoother appearance. See this
#'   \url{https://github.com/mbloch/mapshaper/wiki/Simplification-Tips}{link}
#'   for more information.
#' @param weighting Coefficient for weighting Visvalingam simplification
#' (default is 0.7). Higher values produce smoother output. weighting=0 is
#' equivalent to unweighted Visvalingam simplification.
#' @param keep_shapes Prevent small polygon features from disappearing at high
#'   simplification (default \code{FALSE})
#' @param no_repair disable intersection repair after simplification (default
#'   \code{FALSE}).
#' @param snap Snap together vertices within a small distance threshold to fix
#'   small coordinate misalignment in adjacent polygons. Default \code{TRUE}.
#' @param explode Should multipart polygons be converted to singlepart polygons?
#'   This prevents small shapes from disappearing during simplification if
#'   \code{keep_shapes = TRUE}. Default \code{FALSE}
#' @param drop_null_geometries should Features with null geometries be dropped?
#'   Ignored for \code{Spatial*} objects, as it is always \code{TRUE}.
#' @param snap_interval Specify snapping distance in source units, must be a
#'   numeric. Default \code{NULL}
#' @inheritParams apply_mapshaper_commands
#'
#' @return a simplified representation of the geometry in the same class as the
#'   input
#' @examples
#' # With a simple geojson object
#' poly <- structure('{
#'  "type": "Feature",
#'  "properties": {},
#'  "geometry": {
#'    "type": "Polygon",
#'    "coordinates": [[
#'      [-70.603637, -33.399918],
#'      [-70.614624, -33.395332],
#'      [-70.639343, -33.392466],
#'      [-70.659942, -33.394759],
#'      [-70.683975, -33.404504],
#'      [-70.697021, -33.419406],
#'      [-70.701141, -33.434306],
#'      [-70.700454, -33.446339],
#'      [-70.694274, -33.458369],
#'      [-70.682601, -33.465816],
#'      [-70.668869, -33.472117],
#'      [-70.646209, -33.473835],
#'      [-70.624923, -33.472117],
#'      [-70.609817, -33.468107],
#'      [-70.595397, -33.458369],
#'      [-70.587158, -33.442901],
#'      [-70.587158, -33.426283],
#'      [-70.590591, -33.414248],
#'      [-70.594711, -33.406224],
#'      [-70.603637, -33.399918]
#'    ]]
#'  }
#' }', class = c("json", "geo_json"))
#'
#' ms_simplify(poly, keep = 0.1)
#'
#' # With a SpatialPolygonsDataFrame:
#'
#' poly_sp <- geojsonio::geojson_sp(poly)
#' ms_simplify(poly_sp, keep = 0.5)
#'
#' @export
ms_simplify <- function(input, keep = 0.05, method = NULL, weighting = 0.7,
                        keep_shapes = FALSE, no_repair = FALSE, snap = TRUE,
                        explode = FALSE, force_FC = TRUE, drop_null_geometries = TRUE,
                        snap_interval = NULL, sys = FALSE, sys_mem = 8) {
  UseMethod("ms_simplify")
}

#' @export
ms_simplify.character <- function(input, keep = 0.05, method = NULL, weighting = 0.7,
                                  keep_shapes = FALSE, no_repair = FALSE,
                                  snap = TRUE, explode = FALSE, force_FC = TRUE,
                                  drop_null_geometries = TRUE, snap_interval = NULL, sys = FALSE, sys_mem = 8) {
  input <- check_character_input(input)

  ms_simplify_json(input = input, keep = keep, method = method,
                   weighting = weighting, keep_shapes = keep_shapes,
                   no_repair = no_repair, snap = snap, explode = explode,
                   force_FC = force_FC, drop_null_geometries = drop_null_geometries,
                   snap_interval = snap_interval, sys = sys, sys_mem = sys_mem)

}

#' @export
ms_simplify.geo_json <- function(input, keep = 0.05, method = NULL, weighting = 0.7,
                                 keep_shapes = FALSE, no_repair = FALSE,
                                 snap = TRUE, explode = FALSE, force_FC = TRUE,
                                 drop_null_geometries = TRUE, snap_interval = NULL, sys = FALSE, sys_mem = 8) {
  ms_simplify_json(input = input, keep = keep, method = method,
                   weighting = weighting, keep_shapes = keep_shapes,
                   no_repair = no_repair, snap = snap, explode = explode,
                   force_FC = force_FC, drop_null_geometries = drop_null_geometries,
                   snap_interval = snap_interval, sys = sys, sys_mem = sys_mem)
}

#' @export
ms_simplify.geo_list <- function(input, keep = 0.05, method = NULL,
                                 weighting = 0.7, keep_shapes = FALSE,
                                 no_repair = FALSE, snap = TRUE, explode = FALSE,
                                 force_FC = TRUE, drop_null_geometries = TRUE,
                                 snap_interval = NULL, sys = FALSE, sys_mem = 8) {
  geojson <- geo_list_to_json(input)

  ret <-  ms_simplify_json(input = geojson, keep = keep, method = method,
                           weighting = weighting, keep_shapes = keep_shapes,
                           no_repair = no_repair, snap = snap, explode = explode,
                           force_FC = force_FC, drop_null_geometries = drop_null_geometries,
                           snap_interval = snap_interval, sys = sys, sys_mem = sys_mem)

  geojsonio::geojson_list(ret)
}

#' @export
ms_simplify.SpatialPolygons <- function(input, keep = 0.05, method = NULL, weighting = 0.7,
                                        keep_shapes = FALSE, no_repair = FALSE,
                                        snap = TRUE, explode = FALSE,
                                        force_FC = TRUE, drop_null_geometries = TRUE,
                                        snap_interval = NULL, sys = FALSE, sys_mem = 8) {

  if (!is(input, "Spatial")) stop("input must be a spatial object")

  call <- make_simplify_call(keep = keep, method = method, weighting = weighting,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap, explode = explode, drop_null_geometries = !keep_shapes,
                             snap_interval = snap_interval)

  ms_sp(input, call, sys = sys, sys_mem = sys_mem)

}

#' @export
ms_simplify.SpatialLines <- ms_simplify.SpatialPolygons

#' @export
ms_simplify.sf <- function(input, keep = 0.05, method = NULL, weighting = 0.7,
                           keep_shapes = FALSE, no_repair = FALSE,
                           snap = TRUE, explode = FALSE,
                           force_FC = TRUE, drop_null_geometries = TRUE,
                           snap_interval = NULL, sys = FALSE, sys_mem = 8) {

  if (!all(sf::st_geometry_type(input) %in%
           c("LINESTRING", "MULTILINESTRING", "POLYGON", "MULTIPOLYGON"))) {
    stop("ms_simplify can only operate on (multi)polygons and (multi)linestrings",
         call. = FALSE)
  }

  call <- make_simplify_call(keep = keep, method = method, weighting = weighting,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap, explode = explode,
                             drop_null_geometries = !keep_shapes,
                             snap_interval = snap_interval)

  ms_sf(input, call, sys = sys, sys_mem = sys_mem)
}

#' @export
ms_simplify.sfc <- ms_simplify.sf

ms_simplify_json <- function(input, keep, method, weighting, keep_shapes, no_repair, snap,
                             explode, force_FC, drop_null_geometries, snap_interval, sys, sys_mem) {

  call <- make_simplify_call(keep = keep, method = method, weighting = weighting,
                             keep_shapes = keep_shapes, no_repair = no_repair,
                             snap = snap, explode = explode, drop_null_geometries = drop_null_geometries,
                             snap_interval = snap_interval)

  ret <- apply_mapshaper_commands(data = input, command = call, force_FC = force_FC, sys = sys, sys_mem = sys_mem)

  ret
}

make_simplify_call <- function(keep, method, weighting, keep_shapes, no_repair,
                               snap, explode, drop_null_geometries, snap_interval) {
  if (keep > 1 || keep <= 0) stop("keep must be > 0 and <= 1")
  if (!is.null(snap_interval)) {
    if (!is.numeric(snap_interval)) stop("snap_interval must be a numeric")
    if (snap_interval < 0) stop("snap_interval must be >= 0")
  }
  if (is.null(method)) {
    method <- ""
  } else if (method == "vis") {
    method <- "visvalingam"
  } else if (!method == "dp") {
    stop("method should be one of 'vis', 'dp', or NULL (to use the default weighted Visvalingam method)")
  }

  if (!is.numeric(weighting)) stop("weighting needs to be numeric.")

  if (explode) explode <- "-explode" else explode <- NULL
  if (snap && !is.null(snap_interval)) snap_interval <- paste0("snap-interval=", snap_interval)
  if (snap) snap <- "snap" else snap <- NULL
  if (keep_shapes) keep_shapes <- "keep-shapes" else keep_shapes <- NULL
  if (no_repair) no_repair <- "no-repair" else no_repair <- NULL
  if (drop_null_geometries) drop_null <- "-filter remove-empty" else drop_null <- NULL

  call <- list(explode, snap, snap_interval, "-simplify",
               keep = format(keep, scientific = FALSE), method,
               weighting = paste0("weighting=",format(weighting, scientific = FALSE)),
               keep_shapes, no_repair, drop_null)

  call
}

ms_de_unit <- function(input) {
  input_columns_units <- vapply(input, inherits, "units", FUN.VALUE = logical(1))
  if(any(input_columns_units)) {
    units_column_names <- names(input_columns_units)[input_columns_units]
    msg <- paste0("Coercing these 'units' columns to class numeric: ",
                  paste(units_column_names, collapse = ", "))
    warning(msg)

    for(i in units_column_names) {
      input[[i]] <- as.numeric(input[[i]])
    }
  }
  input
}
