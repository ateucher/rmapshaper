#' clip
#'
#' @param target the target layer. Can be json or sp class
#' @param clip the clipping layer. Can be json or SpatialPolygonsDataFrame
#'
#' @return clipped target in the same class as the input target
#' @export
clip <- function(target, clip) {
  clip_erase(target, clip, type = "clip")
}

#' erase
#'
#' @param target the target layer. Can be json or sp class
#' @param erase the erase layer. Can be json or SpatialPolygonsDataFrame
#'
#' @return erased target in the same format as the input target
#' @export
erase <- function(target, erase) {
  clip_erase(target, erase, type = "erase")
}

clip_erase <- function(target, clip, type) {
  UseMethod("clip_erase")
}

clip_erase.json <- function(target, clip, type) {
  if (!class(clip) == "json") stop("both target and clip must be json")
  mapshaper_clip(target_geojson, clip_geojson, type = type)
}

#' @importFrom sp proj4string proj4string<- CRS spTransform
clip_erase.SpatialPolygonsDataFrame <- function(target, clip, type) {
  if (!is(target, "Spatial") || !is(clip, "Spatial")) stop("target and clip must be of class sp")

  clipping_proj <- "+init=epsg:4326"
  target_proj <- proj4string(target)

  crs <- CRS(clipping_proj)
  target <- spTransform(target, crs)
  clip <- spTransform(clip, crs)

  target_geojson <- sp_to_GeoJSON(target)
  clip_geojson <- sp_to_GeoJSON(clip)

  result <- mapshaper_clip(target_geojson, clip_geojson, type = type)

  ret <- GeoJSON_to_sp(result[[1]][1], clipping_proj)
  ret <- spTransform(ret, target_proj)
  ret
}

#' @importFrom V8 JS
mapshaper_clip <- function(target_layer, clip_layer, type) {

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
  out <- ms$get(
    "
    (function(){
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
        return_data = mapshaper.internal.exportFileContent(data, outOpts);
      })
      return return_data;
      })()
    "
  )

  as.list(out)
}