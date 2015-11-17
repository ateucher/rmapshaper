#' ms_clip
#'
#' @param target the target layer. Can be json or sp class
#' @param clip the clipping layer. Can be json or SpatialPolygonsDataFrame
#' @param force_FC should the output be forced to be a FeatureCollection (or
#'   Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'   FeatureCollections are more compatible with rgdal::readOGR and
#'   geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'   the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'   will be output.
#'
#' @return clipped target in the same class as the input target
#' @export
ms_clip <- function(target, clip, force_FC = TRUE) {
  clip_erase(target = target, clip = clip, type = "clip", force_FC = force_FC)
}

#'erase
#'
#'@param target the target layer. Can be json or sp class
#'@param erase the erase layer. Can be json or SpatialPolygonsDataFrame.
#'@param force_FC should the output be forced to be a FeatureCollection (or
#'  Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'  the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'  will be output.
#'@return erased target in the same format as the input target
#'@export
ms_erase <- function(target, erase, force_FC = TRUE) {
  clip_erase(target = target, clip = erase, type = "erase", force_FC = force_FC)
}

clip_erase <- function(target, clip, type, force_FC) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE")
  UseMethod("clip_erase")
}

#' @importFrom geojsonio lint
clip_erase.geo_json <- function(target, clip, type, force_FC) {
  if (!is(clip, "geo_json")) stop("both target and clip must be class geo_json")
  if (geojsonio::lint(target) != "valid" ||
      geojsonio::lint(clip) != "valid") {
    stop("both target and clip must be valid geojson objects")
  }
  mapshaper_clip(target = target, clip = clip, type = type, force_FC = force_FC)
}

#' @importFrom sp proj4string proj4string<- CRS spTransform identicalCRS
clip_erase.SpatialPolygonsDataFrame <- function(target, clip, type, force_FC) {
  if (!is(target, "Spatial") || !is(clip, "Spatial")) stop("target and clip must be of class sp")

  target_proj <- proj4string(target)

  if (!identicalCRS(target, clip)) {
    warning("target and ", type, " do not have identical CRSs. Transforming ",
            type, " to target CRS")
    clip <- spTransform(clip, target_proj)
  }

  target_geojson <- sp_to_GeoJSON(target)
  clip_geojson <- sp_to_GeoJSON(clip)

  result <- mapshaper_clip(target = target_geojson, clip = clip_geojson,
                           type = type, force_FC = force_FC)

  ret <- GeoJSON_to_sp(result, target_proj)
  ret
}

#' @importFrom V8 JS
mapshaper_clip <- function(target_layer, clip_layer, type, force_FC) {

  ## Import the layers into the V8 session
  ms$eval(paste0('var target_geojson = ', target_layer))
  ms$eval(paste0('var clip_geojson = ', clip_layer))

  ## convert geojson to mapshaper datasets, give each layer a name which can be
  ## referred to in the commands as target and clipping layer
  ms$eval('var target_layer = mapshaper.internal.importFileContent(target_geojson, null, {});
           target_layer.layers[0].name = "target_layer";')
  ms$eval('var clip_layer = mapshaper.internal.importFileContent(clip_geojson, null, {});
           clip_layer.layers[0].name = "clip_layer";')

  ## Merge the datasets into one that can be passed on to runCommand
  ms$eval('var dataset = mapshaper.internal.mergeDatasets([target_layer, clip_layer]);')

  ## Construct the command string; referring to layer names as assigned above
  command <- paste0("-", type,
                    " target=target_layer source=clip_layer -o format=geojson")

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

  structure(out, class = c("json", "geo_json"))
}