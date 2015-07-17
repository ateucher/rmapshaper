#' Topologically-aware simplification of spatial objects.
#'
#' Uses \href{https://github.com/mbloch/mapshaper}{mapshaper} to simplify
#' polygons. It is a Node library, so you need to have Node installed to use it:
#' \url{https://nodejs.org/download/}. Then install mapshaper on the command
#' line with: \code{npm install -g mapshaper}.
#'
#' @importFrom rgdal readOGR writeOGR ogrListLayers
#' @importFrom sp proj4string proj4string<-
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
#'   \code{TRUE}.
#'
#' @return an \code{sp} object
#' @export
simplify <- function(sp_obj, keep = 0.05, method = "vis", keep_shapes = TRUE,
                     no_repair = FALSE, auto_snap = TRUE) {

  if (system("mapshaper --version") == 127L) {
    stop("You do not appear to have mapshaper installed. If you have node.js ",
         "installed on your system, type 'npm install -g mapshaper' on the ",
         "command line. If you don't have node installed, install it from ",
         "http://nodejs.org/, then run the above command.")
  }

  if (!is(sp_obj, "Spatial")) stop("sp_obj must be a spatial object")
  if (keep > 1 || keep < 0) stop("keep must be in the range 0-1")

  if (method == "vis") {
    method <- "visvalingam"
  } else if (!(method == "dp")) {
    stop("method should be one of 'vis' or 'dp'")
  }

  if (keep_shapes) keep_shapes <- "keep-shapes" else keep_shapes <- ""

  if (no_repair) no_repair <- "no-repair" else no_repair <- ""

  if (auto_snap) auto_snap <- "auto-snap" else auto_snap <- ""

  tmp_dir <- tempdir()
  infile <- file.path(tmp_dir, "tempfile.shp")
  writeOGR(sp_obj, dsn = tmp_dir, layer = "tempfile", driver = "ESRI Shapefile",
           overwrite_layer = TRUE, delete_dsn = TRUE)

  outfile <- file.path(tempdir(), "myoutfile.geojson")

  call <- sprintf("mapshaper %s %s -simplify %s %s %s %s -o %s force", infile,
                  auto_snap, keep, method, keep_shapes, no_repair, outfile)
  call <- gsub("\\s+", " ", call)
  system(call)

  lyr <- ogrListLayers(outfile)[1]
  ret <- readOGR(outfile, layer = lyr, stringsAsFactors = FALSE)

  # Need to reassign the projection as it is lost
  proj4string(ret) <- suppressWarnings(proj4string(sp_obj))
  ret

}

