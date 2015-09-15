## Most of this code courtesy of Kent Russell (GitHub: @timelyportfolio;
## twitter: @klr)
library(V8)

# get a place to work
ctx <- new_context()

# source mapshaper.js (which is from
# https://github.com/mbloch/mapshaper/blob/master/mapshaper.js)
ctx$source('./inst/mapshaper/mapshaper-browserify.js')

# check to make sure mapshaper is there
# ctx$get('Object.keys(mapshaper)')

# run_mapshaper_command <- function(data, command) {
#   ctx$eval(paste0('var command = mapshaper.internal.parseCommands("',
#                   command, '")'))
#
#   ctx$eval(paste0('var data = ', data))
#
#   out <- ctx$get(
#     "
#     (function(){
#       var return_data = {};
#       mapshaper.runCommand(
#         command[0],
#         mapshaper.internal.importFileContent(data, null, {}),
#         function(err,data){
#           // This chunk from Mapshaper.ProcessFileContent to get output options:
#           // if last command is -o, use -o options for exporting
#           outCmd = command[command.length-1];
#           if (outCmd && outCmd.name == 'o') {
#             outOpts = command.pop().options;
#           } else {
#             outOpts = {};
#           }
#           // Convert dataset to geojson for export
#           // (or if other format supplied in output options)
#           return_data = mapshaper.internal.exportFileContent(data, outOpts);
#         }
#       )
#     return return_data;
#     })()
#     "
#   )
#
#   as.list(out)
# }

poly <- '{
  "type": "FeatureCollection",
  "features": [
  {
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates": [
  [
  [-114.345703125, 39.4369879],
  [-116.4534998, 37.18979823791],
  [-118.4534998, 38.17698709],
  [-115.345703125, 43.576878],
  [-106.611328125, 43.4529188935547],
  [-105.092834092, 46.20938402],
  [-106.66859, 39.4389646],
  [-103.6117867, 36.436756],
  [-114.34579879, 39.4361929]
  ]
  ]
  },
  "properties": {"id":"foobar"}
  }
  ]
  }'

clip_poly <- '{
"type": "Feature",
"geometry": {
"type": "Polygon",
"coordinates": [
[
  [-114.345703125, 39.4361929993141],
  [-114.345703125, 43.4529188935547],
  [-106.611328125, 43.4529188935547],
  [-106.611328125, 39.4361929993141],
  [-114.345703125, 39.4361929993141]
  ] ]
}
}'

# run_mapshaper_command(poly, "-simplify 0.4 visvalingam")

mapshaper_clip <- function(target_layer, clip_layer) {

  ctx$eval(paste0('var target_geojson = ', JS(target_layer)))
  ctx$eval(paste0('var clip_geojson = ', JS(clip_layer)))
  ctx$eval('var return_data = {};')
  ctx$eval('var target_layer = mapshaper.internal.importFileContent(target_geojson, null, {});')
  ctx$eval('var clip_layer = mapshaper.internal.importFileContent(clip_geojson, null, {});')
  ctx$eval("var outputLayer = mapshaper.clipLayers(target_layer.layers, clip_layer.layers[0], clip_layer);")

  out <- ctx$get(
    "
    (function(){
        // This chunk from Mapshaper.ProcessFileContent to get output options:
        // if last command is -o, use -o options for exporting
        //outCmd = command[command.length-1];
        //if (outCmd && outCmd.name == 'o') {
        //outOpts = command.pop().options;
        //} else {
        //outOpts = {};
        //}
        // Convert dataset to geojson for export
        // (or if other format supplied in output options)
        return_data = mapshaper.internal.exportFileContent(outputLayer, {});
        return return_data;
    })()
    "
  )

  as.list(out)
}

debug(mapshaper_clip)
mapshaper_clip(poly, clip_poly)
