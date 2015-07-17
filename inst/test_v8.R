## To get the mapshaper library ready:
##
## npm install mapshaper
## npm install -g browserify
## echo "global.mapshaper = require('mapshaper');" > in.js
## browserify in.js -o mapshaper-bundle.js
## put mapshaper-bundle.js in /inst/mapshaper

library(V8)
library(geojsonio)
library(bcmaps)

mapshaper <- "inst/mapshaper/mapshaper-bundle.js"
ms <- new_context()
ms$source(mapshaper)
# Get setTimeout
ms$source("inst/timers/timers.js")
# Get setImmediate
ms$source("inst/setImmediate/setImmediate.js")

callback <- "function(Error, data) {
  if (Error) {
console.log(Error);
return;
}
var output = JSON.parse(data);
return output;
}"

bc_gj <- unclass(geojson_json(bc_bound))

test <- "-simplify 0.05 visvalingam"

## Closest to working here:
foo <- ms$call("mapshaper.applyCommands", test, bc_gj, callback)

ms$call(sprintf("var foo = mapshaper.runCommands(%s, '-i -simplify 5%% visvalingam keep-shapes'", bc_gj))

ms$assign('bound', bc_gj)
ms$eval(paste0("var foo = mapshaper.runCommands('", bc_gj, " -simplify 5% visvalingam keep-shapes', ", callback,")"))
