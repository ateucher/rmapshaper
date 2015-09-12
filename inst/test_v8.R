library(V8)
library(geojsonio)

mapshaper <- "inst/mapshaper/mapshaper.js"
ms <- new_context()
ms$source(mapshaper)
# Get setTimeout
ms$source("inst/timers/timers.js")
# # Get setImmediate
# ms$source("inst/setImmediate/setImmediate.js")

callback <- "function(Error, data) {
  if (Error) console.error(Error);
  console.log(data);
}"

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
  "properties": {"id": "foobar"}
}
]
}'

# file <- system.file("examples", "california.geojson", package = "geojsonio")
# test_data <- as.json(geojson_read(file))
# test_data <- paste0(readLines(file), collapse = "")
test_cmd <- "-simplify 0.4 visvalingam"

ms$assign("cb", JS(callback))
ms$call("mapshaper.applyCommands", test_cmd, poly, JS(callback)) # returns NULL

## try in the V8 console
ms$assign("poly", poly)
ms$console() # javascript follows in the V8 console
mapshaper.applyCommands("-simplify 0.4 visvalingam", poly, cb); // null
typeof(cb) // function
typeof(poly) // string
poly // looks ok??
exit
## end of javascrpt
