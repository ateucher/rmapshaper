#' Remove features or portions of features that fall outside a clipping area.
#'
#' Removes portions of the target layer that fall outside the clipping layer or bounding box.
#'
#' @param target the target layer from which to remove portions. Can be geo_json or sp class
#' @param clip the clipping layer. Can be geo_json or SpatialPolygonsDataFrame
#' @param bbox supply a bounding box instead of a clippling layer to extract from
#'   the target layer. Supply as a numeric vector: \code{c(minX, minY, maxX, maxY)}.
#' @param force_FC should the output be forced to be a FeatureCollection (or
#'   Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'   FeatureCollections are more compatible with rgdal::readOGR and
#'   geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'   the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'   will be output.
#'
#' @return clipped target in the same class as the input target
#' @export
ms_clip <- function(target, clip = NULL, bbox = NULL, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_clip")
}

#' @describeIn ms_clip Method for geo_json objects
#' @export
ms_clip.geo_json <- function(target, clip = NULL, bbox = NULL, force_FC = TRUE) {
  clip_erase_json(target = target, overlay = clip, type = "clip", bbox = bbox, force_FC = force_FC)
}

#' @describeIn ms_clip Method for geo_list objects
#' @export
ms_clip.geo_list <- function(target, clip = NULL, bbox = NULL, force_FC = TRUE) {
  clip_erase_geo_list(target = target, overlay = clip, type = "clip", bbox = bbox, force_FC = force_FC)
}

#' @describeIn ms_clip Method for SpatialPolygonsDataFrame objects
#' @export
ms_clip.SpatialPolygonsDataFrame <- function(target, clip = NULL, bbox = NULL, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay = clip, type = "clip", bbox = bbox, force_FC = force_FC)
}

#' Remove features or portions of features that fall inside a specified area
#'
#' Removes portions of the target layer that fall inside the erasing layer or bounding box.
#'
#'@param target the target layer from which to remove portions. Can be geo_json or sp class
#'@param erase the erasing layer. Can be geo_json or SpatialPolygonsDataFrame.
#' @param bbox supply a bounding box instead of an erasing layer to remove from
#'   the target layer. Supply as a numeric vector: \code{c(minX, minY, maxX, maxY)}.
#'@param force_FC should the output be forced to be a FeatureCollection (or
#'  Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'  the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'  will be output.
#'@return erased target in the same format as the input target
#'@export
ms_erase <- function(target, erase = NULL, bbox = NULL, force_FC = TRUE) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("ms_erase")
}

#' @describeIn ms_erase Method for geo_json objects
#' @export
ms_erase.geo_json <- function(target, erase = NULL, bbox = NULL, force_FC = TRUE) {
  clip_erase_json(target = target, overlay = erase, type = "erase", bbox = bbox, force_FC = force_FC)
}

#' @describeIn ms_erase Method for geo_list objects
#' @export
ms_erase.geo_list <- function(target, erase = NULL, bbox = NULL, force_FC = TRUE) {
  clip_erase_geo_list(target = target, overlay = erase, type = "erase", bbox = bbox, force_FC = force_FC)
}

#' @describeIn ms_erase Method for SpatialPolygonsDataFrame objects
#' @export
ms_erase.SpatialPolygonsDataFrame <- function(target, erase = NULL, bbox = NULL, force_FC = TRUE) {
  clip_erase_sp(target = target, overlay = erase, type = "erase", bbox = bbox, force_FC = force_FC)
}

clip_erase_json <- function(target, overlay, bbox, type, force_FC) {

  check_overlay_bbox(overlay = overlay, bbox = bbox, type = type)

  if (geojsonio::lint(target) != "valid") stop("target is not a valid geo_json object")

  if (is.null(bbox)) {
    if (!is(overlay, "geo_json")) stop("both target and ", type, " must be class geo_json")
    if (geojsonio::lint(overlay) != "valid") stop("overlay is not a valid geo_json object")
  }

  mapshaper_clip_erase(target_layer = target, overlay_layer = overlay, type = type, bbox = bbox, force_FC = force_FC)
}

clip_erase_geo_list <- function(target, overlay, bbox, type, force_FC) {

  check_overlay_bbox(overlay = overlay, bbox = bbox, type = type)

  if (is.null(bbox)) {
    if (!is(overlay, "geo_list")) stop("both target and ", type, " must be class geo_list")
    overlay <- geojsonio::geojson_json(overlay)
  }
  target <- geojsonio::geojson_json(target)
  ret <- clip_erase_json(target = target, overlay = overlay, type = type, bbox = bbox, force_FC = force_FC)
  geojsonio::geojson_list(ret)
}

clip_erase_sp <- function(target, overlay, bbox, type, force_FC) {

  check_overlay_bbox(overlay = overlay, bbox = bbox, type = type)

  target_proj <- sp::proj4string(target)

  if (is.null(bbox)) {
    if (!is(overlay, "Spatial")) stop("target and ", type, " must be of class sp")
    if (!sp::identicalCRS(target, overlay)) {
      warning("target and ", type, " do not have identical CRSs. Transforming ",
              type, " to target CRS")
      overlay <- sp::spTransform(overlay, target_proj)
    }
    overlay_geojson <- sp_to_GeoJSON(overlay)
  }

  target_geojson <- sp_to_GeoJSON(target)

  result <- mapshaper_clip_erase(target_layer = target_geojson, overlay_layer = overlay_geojson,
                           type = type, bbox = bbox, force_FC = force_FC)

  ret <- GeoJSON_to_sp(result, target_proj)
  ret
}

check_overlay_bbox <- function(overlay, bbox, type) {

  if (is.null(overlay)) {
    if (is.null(bbox)) {
      stop("You must specificy either a bounding box or a ", type, " polygon.")
    }
    if (length(bbox) != 4 || !is.numeric(bbox)) {
      stop("bbox must be a numeric vector of length 4")
    }
  }

  if (!is.null(overlay) && !is.null(bbox)) {
    stop("Please only specify either a bounding box or a ", type, " polygon.")
  }

  invisible(NULL)
}

mapshaper_clip_erase <- function(target_layer, overlay_layer, bbox, type, force_FC) {

  if (!is.null(bbox)) {
    cmd <- paste0("-", type, " bbox=",paste0(bbox, collapse = ","), "")
    out <- apply_mapshaper_commands(target_layer, cmd, force_FC = force_FC)
  } else if (!is.null(overlay_layer)) {
    ## Import the layers into the V8 session
    ms$eval(paste0('var target_geojson = ', target_layer))
    ms$eval(paste0('var overlay_geojson = ', overlay_layer))

    ## convert geojson to mapshaper datasets, give each layer a name which can be
    ## referred to in the commands as target and clipping layer
    ms$eval('var target_layer = mapshaper.internal.importFileContent(target_geojson, null, {});
           target_layer.layers[0].name = "target_layer";')
    ms$eval('var overlay_layer = mapshaper.internal.importFileContent(overlay_geojson, null, {});
           overlay_layer.layers[0].name = "overlay_layer";')

    ## Merge the datasets into one that can be passed on to runCommand
    ms$eval('var dataset = mapshaper.internal.mergeDatasets([target_layer, overlay_layer]);')

    ## Construct the command string; referring to layer names as assigned above
    command <- paste0("-", type,
                      " target=target_layer source=overlay_layer -o format=geojson")

    ## Parse the commands
    ms$eval(paste0('var command = mapshaper.internal.parseCommands("',
                   command, '")'))

    ## use runCommand to run the clipping function on the merged dataset and return
    ## it to R
    # out <-
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