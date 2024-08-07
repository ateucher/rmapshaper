#' Remove features or portions of features that fall outside a clipping area.
#'
#' Removes portions of the target layer that fall outside the clipping layer or bounding box.
#'
#' @param target the target layer from which to remove portions. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} points, lines, or polygons;
#'  \item \code{SpatialPolygons}, \code{SpatialLines}, \code{SpatialPoints};
#'  \item \code{sf} or \code{sfc} points, lines, or polygons object
#'  }
#' @param clip the clipping layer (polygon). One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{SpatialPolygons*};
#'  \item \code{sf} or \code{sfc} polygons object
#' }
#' @param bbox supply a bounding box instead of a clipping layer to extract from
#'   the target layer. Supply as a numeric vector: \code{c(minX, minY, maxX, maxY)}.
#' @param remove_slivers Remove tiny sliver polygons created by clipping. (Default \code{FALSE})
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet gj2008
#'
#' @return clipped target in the same class as the input target
#'
#' @examples
#'
#' if (rmapshaper:::v8_version() >= "6") {
#'   library(geojsonsf, quietly = TRUE)
#'   library(sf)
#'
#'   poly <- structure("{\"type\":\"FeatureCollection\",
#'     \"features\":[{\"type\":\"Feature\",\"properties\":{},
#'     \"geometry\":{\"type\":\"Polygon\",\"coordinates\":
#'     [[[52.8658,-44.7219],[53.7702,-40.4873],[55.3204,-37.5579],
#'     [56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],
#'     [58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],
#'     [55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],
#'     [52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],
#'     [52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],
#'     [50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],
#'     [52.8658,-44.7219]]]}}]}", class = c("geojson", "json"))
#'   poly <- geojson_sf(poly)
#'   plot(poly)
#'
#'   clip_poly <- structure('{
#'   "type": "Feature",
#'   "properties": {},
#'   "geometry": {
#'   "type": "Polygon",
#'   "coordinates": [
#'   [
#'   [51, -40],
#'   [55, -40],
#'   [55, -45],
#'   [51, -45],
#'   [51, -40]
#'   ]
#'   ]
#'   }
#'   }', class = c("geojson", "json"))
#'   clip_poly <- geojson_sf(clip_poly)
#'   plot(clip_poly)
#'
#'   out <- ms_clip(poly, clip_poly)
#'   plot(out, add = TRUE)
#' }
#'
#' @export
ms_clip <- function(target, clip = NULL, bbox = NULL, remove_slivers = FALSE, ...) {
  stop_for_old_v8()
  UseMethod("ms_clip")
}

#' @export
ms_clip.character <- function(target, clip = NULL, bbox = NULL,
                              remove_slivers = FALSE, ...) {
  target <- check_character_input(target)

  clip_erase_json(target = target, overlay_layer = clip, type = "clip",
                  remove_slivers = remove_slivers, bbox = bbox, ...)

}

#' @export
ms_clip.json <- function(target, clip = NULL, bbox = NULL, remove_slivers = FALSE, ...) {
  clip_erase_json(target = target, overlay_layer = clip, type = "clip",
                  remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_clip.SpatialPolygons <- function(target, clip = NULL, bbox = NULL,
                                    remove_slivers = FALSE, ...) {
  clip_erase_sp(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_clip.SpatialLines <- function(target, clip = NULL, bbox = NULL,
                                 remove_slivers = FALSE, ...) {
  clip_erase_sp(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_clip.SpatialPoints <- function(target, clip = NULL, bbox = NULL,
                                  remove_slivers = FALSE, ...) {
  clip_erase_sp(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_clip.sf <- function(target, clip = NULL, bbox = NULL,
                       remove_slivers = FALSE, ...) {
  clip_erase_sf(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_clip.sfc <- function(target, clip = NULL, bbox = NULL,
                       remove_slivers = FALSE, ...) {
  clip_erase_sf(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' Remove features or portions of features that fall inside a specified area
#'
#' Removes portions of the target layer that fall inside the erasing layer or bounding box.
#'
#' @param target the target layer from which to remove portions. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} points, lines, or polygons;
#'  \item \code{SpatialPolygons}, \code{SpatialLines}, \code{SpatialPoints}
#'  }
#' @param erase the erase layer (polygon). One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{SpatialPolygons*}
#' }
#' @param bbox supply a bounding box instead of an erasing layer to remove from
#'   the target layer. Supply as a numeric vector: \code{c(minX, minY, maxX, maxY)}.
#' @param remove_slivers Remove tiny sliver polygons created by erasing. (Default \code{FALSE})
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet gj2008
#'
#' @return erased target in the same format as the input target
#' @examples
#' if (rmapshaper:::v8_version() >= "6") {
#'   library(geojsonsf, quietly = TRUE)
#'   library(sf)
#'
#'   points <- structure("{\"type\":\"FeatureCollection\",
#'     \"features\":[{\"type\":\"Feature\",\"properties\":{},
#'     \"geometry\":{\"type\":\"Point\",\"coordinates\":
#'     [52.8658,-44.7219]}},{\"type\":\"Feature\",\"properties\":{},
#'     \"geometry\":{\"type\":\"Point\",\"coordinates\":
#'     [53.7702,-40.4873]}},{\"type\":\"Feature\",\"properties\":{},
#'     \"geometry\":{\"type\":\"Point\",\"coordinates\":[55.3204,-37.5579]}},
#'     {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'     {\"type\":\"Point\",\"coordinates\":[56.2757,-37.917]}},
#'     {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'     {\"type\":\"Point\",\"coordinates\":[56.184,-40.6443]}},
#'     {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'     {\"type\":\"Point\",\"coordinates\":[61.0835,-40.7529]}},
#'     {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'     {\"type\":\"Point\",\"coordinates\":[58.0202,-43.634]}}]}",
#'     class = c("geojson", "json"))
#'   points <- geojson_sf(points)
#'   plot(points)
#'
#'   erase_poly <- structure('{
#'   "type": "Feature",
#'   "properties": {},
#'   "geometry": {
#'   "type": "Polygon",
#'   "coordinates": [
#'   [
#'   [51, -40],
#'   [55, -40],
#'   [55, -45],
#'   [51, -45],
#'   [51, -40]
#'   ]
#'   ]
#'   }
#'   }', class = c("geojson", "json"))
#'   erase_poly <- geojson_sf(erase_poly)
#'
#'   out <- ms_erase(points, erase_poly)
#'   plot(out, add = TRUE)
#' }
#'
#'@export
ms_erase <- function(target, erase = NULL, bbox = NULL,
                     remove_slivers = FALSE, ...) {
  stop_for_old_v8()
  UseMethod("ms_erase")
}

#' @export
ms_erase.character <- function(target, erase = NULL, bbox = NULL,
                               remove_slivers = FALSE, ...) {
  target <- check_character_input(target)

  clip_erase_json(target = target, overlay_layer = erase, type = "erase",
                  remove_slivers = remove_slivers, bbox = bbox, ...)

}

#' @export
ms_erase.json <- function(target, erase = NULL, bbox = NULL,
                              remove_slivers = FALSE, ...) {
  clip_erase_json(target = target, overlay_layer = erase, type = "erase",
                  remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_erase.SpatialPolygons <- function(target, erase = NULL, bbox = NULL,
                                     remove_slivers = FALSE, ...) {
  clip_erase_sp(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_erase.SpatialLines <- function(target, erase = NULL, bbox = NULL,
                                  remove_slivers = FALSE, ...) {
  clip_erase_sp(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_erase.SpatialPoints <- function(target, erase = NULL, bbox = NULL,
                                   remove_slivers = FALSE, ...) {
  clip_erase_sp(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_erase.sf <- function(target, erase = NULL, bbox = NULL,
                       remove_slivers = FALSE, ...) {
  clip_erase_sf(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

#' @export
ms_erase.sfc <- function(target, erase = NULL, bbox = NULL,
                        remove_slivers = FALSE, ...) {
  clip_erase_sf(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, ...)
}

clip_erase_json <- function(target, overlay_layer, bbox, remove_slivers, type,
                            force_FC = TRUE, sys = FALSE,
                            sys_mem = getOption("mapshaper.sys_mem", default = 8),
                            quiet = getOption("mapshaper.sys_quiet", default = FALSE),
                            gj2008 = FALSE) {

  check_overlay_bbox(overlay_layer = overlay_layer, bbox = bbox, type = type)

  if (!is.null(overlay_layer)) {
    overlay_layer <- check_character_input(overlay_layer)
  }

  mapshaper_clip_erase(target_layer = target, overlay_layer = overlay_layer, type = type,
                       remove_slivers = remove_slivers, bbox = bbox,
                       force_FC = force_FC, sys = sys, sys_mem = sys_mem, quiet = quiet,
                       gj2008 = gj2008)
}

clip_erase_sp <- function(target, overlay_layer, bbox, type, remove_slivers,
                          force_FC = TRUE, sys = FALSE,
                          sys_mem = getOption("mapshaper.sys_mem", default = 8),
                          quiet = getOption("mapshaper.sys_quiet", default = FALSE),
                          gj2008 = FALSE) {

  check_overlay_bbox(overlay_layer = overlay_layer, bbox = bbox, type = type)

  target_proj <- methods::slot(target, "proj4string")

  if (is.null(bbox)) {
    if (!is(overlay_layer, "SpatialPolygons")) stop(type, " must be of class SpatialPolygons or SpatialPolygonsDataFrame")
    if (!sp::identicalCRS(target, overlay_layer)) {
      stop("target and ", type, " do not have identical CRS.", call. = FALSE)
    }
    overlay_geojson <- sp_to_GeoJSON(overlay_layer, file = sys)
  }

  target_geojson <- sp_to_GeoJSON(target, file = sys)

  result <- mapshaper_clip_erase(target_layer = target_geojson,
                                 overlay_layer = overlay_geojson,
                                 type = type, remove_slivers = remove_slivers,
                                 bbox = bbox, force_FC = TRUE, sys = sys,
                                 sys_mem = sys_mem, quiet = quiet, gj2008 = gj2008)

  ret <- GeoJSON_to_sp(result, target_proj)

  # remove data slot if input didn't have one
  if (!.hasSlot(target, "data")) {
    ret <- as(ret, class(target)[1])
  }

  ret
}

clip_erase_sf <- function(target, overlay_layer, bbox, type, remove_slivers,
                          force_FC = TRUE, sys = FALSE,
                          sys_mem = getOption("mapshaper.sys_mem", default = 8),
                          quiet = getOption("mapshaper.sys_quiet", default = FALSE),
                          gj2008 = FALSE) {

  check_overlay_bbox(overlay_layer = overlay_layer, bbox = bbox, type = type)

  has_data <- is(target, "sf")
  if (has_data) {
    classes <- col_classes(target)
  }

  target_proj <- sf::st_crs(target)

  if (is.null(bbox)) {
    if (!(inherits(overlay_layer, c("sf", "sfc"))) ||
        !all(sf::st_is(overlay_layer, c("POLYGON", "MULTIPOLYGON")))) {
      stop(type, " must be an sf or sfc object with POLYGON or MULTIPLOYGON geometry")
    }
    if (target_proj != sf::st_crs(overlay_layer)) {
      stop("target and ", type, " do not have identical CRS.", call. = FALSE)
    }
    overlay_geojson <- sf_to_GeoJSON(overlay_layer, file = sys)
  }

  target_geojson <- sf_to_GeoJSON(target, file = sys)

  result <- mapshaper_clip_erase(
    target_layer = target_geojson,
    overlay_layer = overlay_geojson,
    bbox = bbox,
    type = type,
    remove_slivers = remove_slivers,
    force_FC = TRUE,
    sys = sys,
    sys_mem = sys_mem,
    quiet = quiet,
    gj2008 = gj2008
  )

  ret <- GeoJSON_to_sf(result, target_proj)

  # remove data slot if input didn't have one
  if (!has_data) {
    ret <- sf::st_geometry(ret)
  }  else {
    ret <- restore_classes(ret, classes)
  }

  ret
}

check_overlay_bbox <- function(overlay_layer, bbox, type) {

  if (is.null(overlay_layer)) {
    if (is.null(bbox)) {
      stop("You must specificy either a bounding box or a ", type, " polygon.")
    }
    if (length(bbox) != 4 || !is.numeric(bbox)) {
      stop("bbox must be a numeric vector of length 4")
    }
  }

  if (!is.null(overlay_layer) && !is.null(bbox)) {
    stop("Please only specify either a bounding box or a ", type, " polygon.")
  }

  invisible(NULL)
}

mapshaper_clip_erase <- function(target_layer, overlay_layer, bbox, type,
                                 remove_slivers, force_FC = TRUE, sys = FALSE,
                                 sys_mem = getOption("mapshaper.sys_mem", default = 8),
                                 quiet = getOption("mapshaper.sys_quiet", default = FALSE),
                                 gj2008 = FALSE) {


  remove_slivers <- ifelse(remove_slivers, "remove-slivers", "")

  if (!is.null(bbox)) {
    cmd <- paste0("-", type, " bbox=",paste0(bbox, collapse = ","), " ",
                  remove_slivers)
    out <- apply_mapshaper_commands(
      target_layer,
      cmd,
      force_FC = force_FC,
      sys = sys,
      sys_mem = sys_mem,
      quiet = quiet,
      gj2008 = gj2008
    )
  } else if (!is.null(overlay_layer)) {

    if (sys) {
      on.exit(unlink(c(target_layer, overlay_layer)), add = TRUE)
      cmd <- paste0("-", type)
      out <- sys_mapshaper(
        data = target_layer,
        data2 = overlay_layer,
        command = cmd,
        force_FC = force_FC,
        sys_mem = sys_mem,
        quiet = quiet,
        gj2008 = gj2008
      )
    } else {

      ms <- ms_make_ctx()
      ## Import the layers into the V8 session
      ms$assign("target_geojson", target_layer)
      ms$assign("overlay_geojson", overlay_layer)

      # Combine them into a single object
      ms$eval("
      var data_layers = {'target.json': target_geojson, 'overlay.json': overlay_geojson}
    ")

      ## Construct the command string; referring to layer names as assigned above
      command <- paste0("-i overlay.json -i target.json -", type,
                        " overlay ",
                        remove_slivers)

      command <- paste(command, "-o format=geojson")

      if (force_FC) {
        # this must come after -o format=geojson
        command <- paste(command, fc_command())
      }

      if (isTRUE(gj2008)) {
        command <- paste(command, "gj2008")
      }

      # Create an object to hold the return value
      ms$eval("var return_data;")

      # Run the commands on the data
      ms$eval(paste0('mapshaper.applyCommands("',
                     command,
                     '", data_layers, ',
                     callback(), ')'))

      out <- ms$get("return_data")[["target.json"]]
      out <- class_geo_json(out)
    }
  }
  out
}
