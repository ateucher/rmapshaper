#' Remove features or portions of features that fall outside a clipping area.
#'
#' Removes portions of the target layer that fall outside the clipping layer or bounding box.
#'
#' @param target the target layer from which to remove portions. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} points, lines, or polygons;
#'  \item \code{geo_list} points, lines, or polygons;
#'  \item \code{SpatialPolygons}, \code{SpatialLines}, \code{SpatialPoints};
#'  \item \code{sf} or \code{sfc} points, lines, or polygons object
#'  }
#' @param clip the clipping layer (polygon). One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{geo_list} polygons;
#'  \item \code{SpatialPolygons*};
#'  \item \code{sf} or \code{sfc} polygons object
#' }
#' @param bbox supply a bounding box instead of a clipping layer to extract from
#'   the target layer. Supply as a numeric vector: \code{c(minX, minY, maxX, maxY)}.
#' @param remove_slivers Remove tiny sliver polygons created by clipping. (Default \code{FALSE})
#' @param force_FC should the output be forced to be a \code{FeatureCollection} even
#' if there are no attributes? Default \code{TRUE}.
#'  \code{FeatureCollections} are more compatible with \code{rgdal::readOGR} and
#'  \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no attributes associated with
#'  the geometries, a \code{GeometryCollection} will be output. Ignored for \code{Spatial}
#'  objects, as the output is always the same as the input.
#'
#' @return clipped target in the same class as the input target
#'
#' @examples
#' library(geojsonio, quietly = TRUE)
#' library(sp)
#'
#' poly <- structure("{\"type\":\"FeatureCollection\",
#'   \"features\":[{\"type\":\"Feature\",\"properties\":{},
#'   \"geometry\":{\"type\":\"Polygon\",\"coordinates\":
#'   [[[52.8658,-44.7219],[53.7702,-40.4873],[55.3204,-37.5579],
#'   [56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],
#'   [58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],
#'   [55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],
#'   [52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],
#'   [52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],
#'   [50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],
#'   [52.8658,-44.7219]]]}}]}", class = c("json", "geo_json"))
#' poly <- geojson_sp(poly)
#' plot(poly)
#'
#' clip_poly <- structure('{
#' "type": "Feature",
#' "properties": {},
#' "geometry": {
#' "type": "Polygon",
#' "coordinates": [
#' [
#' [51, -40],
#' [55, -40],
#' [55, -45],
#' [51, -45],
#' [51, -40]
#' ]
#' ]
#' }
#' }', class = c("json", "geo_json"))
#' clip_poly <- geojson_sp(clip_poly)
#' plot(clip_poly)
#'
#' out <- ms_clip(poly, clip_poly)
#' plot(out, add = TRUE)
#'
#' @export
ms_clip <- function(target, clip = NULL, bbox = NULL, remove_slivers = FALSE,
                    force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_clip")
}

#' @export
ms_clip.character <- function(target, clip = NULL, bbox = NULL,
                              remove_slivers = FALSE, force_FC = TRUE) {
  target <- check_character_input(target)

  clip_erase_json(target = target, overlay_layer = clip, type = "clip",
                  remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)

}

#' @export
ms_clip.geo_json <- function(target, clip = NULL, bbox = NULL, remove_slivers = FALSE,
                             force_FC = TRUE) {
  clip_erase_json(target = target, overlay_layer = clip, type = "clip",
                  remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_clip.geo_list <- function(target, clip = NULL, bbox = NULL, remove_slivers = FALSE,
                             force_FC = TRUE) {
  clip_erase_geo_list(target = target, overlay_layer = clip, type = "clip",
                      remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_clip.SpatialPolygons <- function(target, clip = NULL, bbox = NULL,
                                    remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_clip.SpatialLines <- function(target, clip = NULL, bbox = NULL,
                                 remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_clip.SpatialPoints <- function(target, clip = NULL, bbox = NULL,
                                  remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_clip.sf <- function(target, clip = NULL, bbox = NULL,
                       remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sf(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_clip.sfc <- function(target, clip = NULL, bbox = NULL,
                       remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sf(target = target, overlay_layer = clip, type = "clip",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' Remove features or portions of features that fall inside a specified area
#'
#' Removes portions of the target layer that fall inside the erasing layer or bounding box.
#'
#' @param target the target layer from which to remove portions. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} points, lines, or polygons;
#'  \item \code{geo_list} points, lines, or polygons;
#'  \item \code{SpatialPolygons}, \code{SpatialLines}, \code{SpatialPoints}
#'  }
#' @param erase the erase layer (polygon). One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{geo_list} polygons;
#'  \item \code{SpatialPolygons*}
#' }
#' @param bbox supply a bounding box instead of an erasing layer to remove from
#'   the target layer. Supply as a numeric vector: \code{c(minX, minY, maxX, maxY)}.
#' @param remove_slivers Remove tiny sliver polygons created by erasing. (Default \code{FALSE})
#' @param force_FC should the output be forced to be a \code{FeatureCollection} even
#' if there are no attributes? Default \code{TRUE}.
#'  \code{FeatureCollections} are more compatible with \code{rgdal::readOGR} and
#'  \code{geojsonio::geojson_sp}. If \code{FALSE} and there are no attributes associated with
#'  the geometries, a \code{GeometryCollection} will be output. Ignored for \code{Spatial}
#'  objects, as the output is always the same class as the input.
#'@return erased target in the same format as the input target
#' @examples
#' library(geojsonio, quietly = TRUE)
#' library(sp)
#'
#' points <- structure("{\"type\":\"FeatureCollection\",
#'   \"features\":[{\"type\":\"Feature\",\"properties\":{},
#'   \"geometry\":{\"type\":\"Point\",\"coordinates\":
#'   [52.8658,-44.7219]}},{\"type\":\"Feature\",\"properties\":{},
#'   \"geometry\":{\"type\":\"Point\",\"coordinates\":
#'   [53.7702,-40.4873]}},{\"type\":\"Feature\",\"properties\":{},
#'   \"geometry\":{\"type\":\"Point\",\"coordinates\":[55.3204,-37.5579]}},
#'   {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'   {\"type\":\"Point\",\"coordinates\":[56.2757,-37.917]}},
#'   {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'   {\"type\":\"Point\",\"coordinates\":[56.184,-40.6443]}},
#'   {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'   {\"type\":\"Point\",\"coordinates\":[61.0835,-40.7529]}},
#'   {\"type\":\"Feature\",\"properties\":{},\"geometry\":
#'   {\"type\":\"Point\",\"coordinates\":[58.0202,-43.634]}}]}",
#'   class = c("json", "geo_json"))
#' points <- geojson_sp(points)
#' plot(points)
#'
#' erase_poly <- structure('{
#' "type": "Feature",
#' "properties": {},
#' "geometry": {
#' "type": "Polygon",
#' "coordinates": [
#' [
#' [51, -40],
#' [55, -40],
#' [55, -45],
#' [51, -45],
#' [51, -40]
#' ]
#' ]
#' }
#' }', class = c("json", "geo_json"))
#' erase_poly <- geojson_sp(erase_poly)
#'
#' out <- ms_erase(points, erase_poly)
#' plot(out, add = TRUE)
#'
#'@export
ms_erase <- function(target, erase = NULL, bbox = NULL,
                     remove_slivers = FALSE, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_erase")
}

#' @export
ms_erase.character <- function(target, erase = NULL, bbox = NULL,
                               remove_slivers = FALSE, force_FC = TRUE) {
  target <- check_character_input(target)

  clip_erase_json(target = target, overlay_layer = erase, type = "erase",
                  remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)

}

#' @export
ms_erase.geo_json <- function(target, erase = NULL, bbox = NULL,
                              remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_json(target = target, overlay_layer = erase, type = "erase",
                  remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_erase.geo_list <- function(target, erase = NULL, bbox = NULL,
                              remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_geo_list(target = target, overlay_layer = erase, type = "erase",
                      remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_erase.SpatialPolygons <- function(target, erase = NULL, bbox = NULL,
                                     remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_erase.SpatialLines <- function(target, erase = NULL, bbox = NULL,
                                  remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_erase.SpatialPoints <- function(target, erase = NULL, bbox = NULL,
                                   remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_erase.sf <- function(target, erase = NULL, bbox = NULL,
                       remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sf(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

#' @export
ms_erase.sfc <- function(target, erase = NULL, bbox = NULL,
                        remove_slivers = FALSE, force_FC = TRUE) {
  clip_erase_sf(target = target, overlay_layer = erase, type = "erase",
                remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

clip_erase_json <- function(target, overlay_layer, bbox, remove_slivers, type,
                            force_FC) {

  check_overlay_bbox(overlay_layer = overlay_layer, bbox = bbox, type = type)

  if (!is.null(overlay_layer)) {
    overlay_layer <- check_character_input(overlay_layer)
  }

  mapshaper_clip_erase(target_layer = target, overlay_layer = overlay_layer, type = type,
                       remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
}

clip_erase_geo_list <- function(target, overlay_layer, bbox, type,
                                remove_slivers, force_FC) {

  check_overlay_bbox(overlay_layer = overlay_layer, bbox = bbox, type = type)

  if (is.null(bbox)) {
    if (!is(overlay_layer, "geo_list")) stop("both target and ", type, " must be class geo_list")
    overlay_layer <- geojsonio::geojson_json(overlay_layer)
  }
  target <- geojsonio::geojson_json(target)
  ret <- clip_erase_json(target = target, overlay_layer = overlay_layer, type = type,
                         remove_slivers = remove_slivers, bbox = bbox, force_FC = force_FC)
  geojsonio::geojson_list(ret)
}

clip_erase_sp <- function(target, overlay_layer, bbox, type, remove_slivers, force_FC) {

  check_overlay_bbox(overlay_layer = overlay_layer, bbox = bbox, type = type)

  target_proj <- sp::proj4string(target)

  if (is.null(bbox)) {
    if (!is(overlay_layer, "SpatialPolygons")) stop(type, " must be of class SpatialPolygons or SpatialPolygonsDataFrame")
    if (!sp::identicalCRS(target, overlay_layer)) {
      warning("target and ", type, " do not have identical CRS. Transforming ",
              type, " to target CRS")
      overlay_layer <- sp::spTransform(overlay_layer, target_proj)
    }
    overlay_geojson <- sp_to_GeoJSON(overlay_layer)
  }

  target_geojson <- sp_to_GeoJSON(target)

  result <- mapshaper_clip_erase(target_layer = target_geojson,
                                 overlay_layer = overlay_geojson,
                                 type = type, remove_slivers = remove_slivers,
                                 bbox = bbox, force_FC = TRUE)

  ret <- GeoJSON_to_sp(result, target_proj)

  # remove data slot if input didn't have one
  if (!.hasSlot(target, "data")) {
    ret <- as(ret, class(target)[1])
  }

  ret
}

clip_erase_sf <- function(target, overlay_layer, bbox, type, remove_slivers, force_FC) {

  check_sf_pkg()

  check_overlay_bbox(overlay_layer = overlay_layer, bbox = bbox, type = type)

  has_data <- is(target, "sf")
  if (has_data) {
    classes <- col_classes(target)
  }

  target_proj <- sf::st_crs(target)

  if (is.null(bbox)) {
    if (!(is(overlay_layer, "sf") && !is(overlay_layer, "sfc")) ||
        !all(sf::st_is(overlay_layer, c("POLYGON", "MULTIPOLYGON")))) {
      stop(type, " must be an sf or sfc object with POLYGON or MULTIPLOYGON geometry")
    }
    if (sf::st_crs(target) != sf::st_crs(overlay_layer)) {
      warning("target and ", type, " do not have identical CRS. Transforming ",
              type, " to target CRS")
      overlay_layer <- sf::st_transform(overlay_layer, target_proj)
    }
    overlay_geojson <- sf_to_GeoJSON(overlay_layer)
  }

  target_geojson <- sf_to_GeoJSON(target)

  result <- mapshaper_clip_erase(target_layer = target_geojson,
                                 overlay_layer = overlay_geojson,
                                 type = type, remove_slivers = remove_slivers,
                                 bbox = bbox, force_FC = TRUE)

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
                                 remove_slivers, force_FC) {

  remove_slivers <- ifelse(remove_slivers, "remove-slivers", "")

  if (!is.null(bbox)) {
    cmd <- paste0("-", type, " bbox=",paste0(bbox, collapse = ","), " ",
                  remove_slivers)
    out <- apply_mapshaper_commands(target_layer, cmd, force_FC = force_FC)
  } else if (!is.null(overlay_layer)) {

    ms <- ms_make_ctx()
    ## Import the layers into the V8 session
    ms$assign("target_geojson", target_layer)
    ms$assign("overlay_geojson", overlay_layer)

    ## convert geojson to mapshaper datasets, give each layer a name which can be
    ## referred to in the commands as target and clipping layer
    ## Then merge the datasets into one that can be passed on to runCommand
    ms$eval('
      var target_layer = mapshaper.internal.importFileContent(target_geojson, null, {});
      target_layer.layers[0].name = "target_layer";
      var overlay_layer = mapshaper.internal.importFileContent(overlay_geojson, null, {});
      overlay_layer.layers[0].name = "overlay_layer";
      var dataset = mapshaper.internal.mergeDatasets([target_layer, overlay_layer]);'
    )


    ## Construct the command string; referring to layer names as assigned above
    command <- paste0("-", type,
                      " target=target_layer source=overlay_layer ",
                      remove_slivers,
                      " -o format=geojson")

    ## Parse the commands
    ms$eval(paste0('var command = mapshaper.internal.parseCommands("',
                   command, '")'))

    ## use runCommand to run the clipping function on the merged dataset and return
    ## it to R
    ms$eval(
      "
      var return_data = {};
      mapshaper.runCommand(command[0], dataset, function(err,data){
        // This chunk from Mapshaper.ProcessFileContent to get output options:
        // if last command is -o, use -o options for exporting
        outCmd = command[command.length-1];
        if (outCmd && outCmd.name == 'o') {
        outOpts = command.pop().options;
        } else {
        outOpts = {};
        }
        // Convert dataset to geojson for export
        // (or if other format supplied in output options)
        return_data = mapshaper.internal.exportFileContent(data, outOpts)[0].content;
      })"
    )

    ## Add a dummy id to force to FeatureCollection
    if (force_FC) {
      add_id_cmd <- add_dummy_id_command()
      ms$eval(paste0(
        "
      // make sure that a FeatureCollection is returned by applying a dummy id
      // to each geometry. Otherwise if there are no attributes (i.e., just
      // geometries, a GeometryCollection is output which readOGR doesn't like)
      mapshaper.applyCommands(\"", add_id_cmd, "\", return_data, function(Error, data) {
          if (Error) console.error(Error);
          return_data = data;
      })"
      ))
    }

    out <- ms$get("return_data")
    out <- class_geo_json(out)
  }
  out
}
