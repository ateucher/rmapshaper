library(V8)
library(geojsonio)

mapshaper <- "inst/mapshaper/mapshaper.js"
ms <- new_context()
ms$source(mapshaper)

geojson_file <- system.file("examples", "california.geojson", package = "geojsonio")
california <- geojson_read(geojson_file)
topojson_file <- system.file("examples", "us_states.topojson", package = "geojsonio")
us_states <- geojson_json(topojson_read(topojson_file))

ms$eval("var return_data;")

callback <- "function(Error, data) {
  if (Error) console.error(Error);
  return_data = data;
}"

# simplify
ms$call("mapshaper.applyCommands", "-simplify 0.05 visvalingam", california, JS(callback))
ms$get("return_data")

# simplify with snapping
ms$call("mapshaper.applyCommands", "snap -simplify 0.05", california, JS(callback))
ms$get("return_data")

# convert to points (centroid)
ms$call("mapshaper.applyCommands", "-points", california, JS(callback))
ms$get("return_data")

# explode then get centroids of all parts
ms$call("mapshaper.applyCommands", "-explode -points", california, JS(callback))
ms$get("return_data")

# rename fields then simplify
ms$call("mapshaper.applyCommands", "snap -rename-fields abbr=abbreviation -simplify 0.05", california, JS(callback))
ms$get("return_data")

# convert to lines
ms$call("mapshaper.applyCommands", "-lines", california, JS(callback))
ms$get("return_data")

# simplify then convert to lines
ms$call("mapshaper.applyCommands", "-simplify 0.05 -lines", california, JS(callback))
ms$get("return_data")

# explode then simplify, not allowing null geometries (i.e., keep all small
# that would otherwise be simplified into non-existence)
ms$call("mapshaper.applyCommands", "-explode -simplify 0.05 keep-shapes", california, JS(callback))
ms$get("return_data")

# explode then dissolve then simplify us states
ms$call("mapshaper.applyCommands", "snap -explode -dissolve -simplify 0.05", us_states, JS(callback))
ms$get("return_data")


###################################################

poly <- '{
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
  ] ]
  }
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

## try in the V8 console
ms$assign("poly", JS(poly))
ms$assign("clip_poly", JS(clip_poly))
ms$assign("cb", JS(callback))
ms$console() # javascript follows in the V8 console
mapshaper.applyCommands("-simplify 0.4 visvalingam", poly, cb);
console.log(return_data);

mapshaper.applyCommands("-clip clip_poly", poly, function(Error, data) {
  if (Error) console.error(Error);
  console.log(data);
})

exit
## end of javascrpt
