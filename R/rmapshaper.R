#' @title rmapshaper: Client for 'mapshaper' for 'Geospatial' Operations
#'
#' @description Edit and simplify 'geojson', 'Spatial', and 'sf' objects.
#' This is wrapper around the 'mapshaper' 'javascript' library by Matthew Bloch
#' \url{https://github.com/mbloch/mapshaper/} to perform topologically-aware
#' polygon simplification, as well as other operations such as clipping,
#' erasing, dissolving, and converting 'multi-part' to 'single-part' geometries.
#'
#' @section rmapshaper functions:
#'
#' All functions
#' \itemize{
#'   \item \code{\link{ms_simplify}} - simplify polygons or lines
#'   \item \code{\link{ms_clip}} - clip an area out of a layer using a polygon layer or a bounding box. Works on polygons, lines, and points
#'   \item \code{\link{ms_erase}} - erase an area from a layer using a polygon layer or a bounding box. Works on polygons, lines, and points
#'   \item \code{\link{ms_dissolve}} - aggregate polygon features, optionally specifying a field to aggregate on. If no field is specified, will merge all polygons into one.
#'   \item \code{\link{ms_explode}} - convert multipart shapes to single part. Works with polygons, lines, and points in geojson format, but currently only with polygons and lines in the `Spatial` classes (not `SpatialMultiPoints` and `SpatialMultiPointsDataFrame`).
#'   \item \code{\link{ms_lines}} - convert polygons to topological boundaries (lines)
#'   \item \code{\link{ms_innerlines}} - convert polygons to shared inner boundaries (lines)
#'   \item \code{\link{ms_points}} - create points from a polygon layer
#'   \item \code{\link{ms_filter_fields}} - Remove fields from the attributes
#'   \item \code{\link{ms_filter_islands}} - Remove small detached polygons
#' }
#'
#' @docType package
#' @author Andy Teucher \email{andy.teucher@@gmail.com}
#' @name rmapshaper
#' @importFrom methods is .hasSlot as slot
#' @importFrom V8 v8
#' @importClassesFrom sp SpatialPoints SpatialLines
NULL
