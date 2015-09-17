#' clip
#'
#' @importFrom sp proj4string proj4string<- CRS spTransform
#' @param target
#' @param clip
#'
#' @return sp
#' @export
clip <- function(target, clip) {
  clip_erase(target, clip, type = "clip")
}

erase <- function(target, clip) {
  clip_erase(target, clip, type = "erase")
}

clip_erase <- function(target, clip, type) {
  if (!is(target, "Spatial") || !is(clip, "Spatial")) stop("target and clip must be of class sp")

  clipping_proj <- "+init=epsg:4326"
  target_proj <- proj4string(target)

  crs <- CRS(clipping_proj)
  target <- spTransform(target, crs)
  clip <- spTransform(clip, crs)

  target_geojson <- sp_to_GeoJSON(target)
  clip_geojson <- sp_to_GeoJSON(clip)

  result <- mapshaper_clip(target_geojson$js, clip_geojson$js, type = type)

  ret <- GeoJSON_to_sp(result[[1]], clipping_proj)
  ret <- spTransform(ret, target_proj)
  ret
}

#' @importFrom V8 JS
mapshaper_clip <- function(target_layer, clip_layer, type) {

  ## Import the layers into the V8 session
  ms$eval(paste0('var target_geojson = ', JS(target_layer)))
  ms$eval(paste0('var clip_geojson = ', JS(clip_layer)))

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