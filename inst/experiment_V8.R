## Most of this code courtesy of Kent Russell (GitHub: @timelyportfolio;
## twitter: @klr)
library(V8)

# get a place to work
ctx <- new_context()

# source mapshaper.js (which is from
# https://github.com/mbloch/mapshaper/blob/master/mapshaper.js)
ctx$source('./inst/mapshaper/mapshaper.js')

# check to make sure mapshaper is there
# ctx$get('Object.keys(mapshaper)')

# run the example from issue #2
ctx$eval(
  'var poly = {
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
  }
  '
)

# see if poly is there
# ctx$get('poly')

# set commands
ctx$eval('var command = mapshaper.internal.parseCommands("-simplify 0.4 visvalingam")')

# to set can do something ugly like this
out <- ctx$get(
"
(function(){
  var return_data = {};
  mapshaper.runCommand(
    command[0],
    mapshaper.internal.importFileContent(poly, null, {}),
    function(err,data){
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
    }
  )
return return_data;
})()
"
)

out[[1]]

