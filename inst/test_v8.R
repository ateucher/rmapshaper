library(V8)
library(geojsonio)

mapshaper <- "inst/mapshaper/mapshaper.js"
ms <- new_context()
ms$source(mapshaper)
# Get setTimeout
# ms$source("inst/timers/timers.js")
# # Get setImmediate
ms$source("inst/setImmediate/setImmediate.js")

callback <- "function(Error, data) {
  if (Error) console.error(Error);
  return data;
}"

# poly <- c(c(-114.345703125,39.436192999314095),
#           c(-114.345703125,43.45291889355468),
#           c(-106.61132812499999,43.45291889355468),
#           c(-106.61132812499999,39.436192999314095),
#           c(-114.345703125,39.436192999314095))
# poly <- geojson_json(poly, geometry = "polygon", pretty=TRUE)

file <- system.file("examples", "california.geojson", package = "geojsonio")
poly <- as.json(geojson_read(file))
# test_data <- paste0(readLines(file), collapse = "")
test_cmd <- "-simplify 0.5 visvalingam"

ms$assign("cb", JS(callback))
ms$call("mapshaper.applyCommands", test_cmd, JS(poly), callback) # returns NULL

## try in the V8 console
# ms$assign("poly", poly)
ms$assign("poly", JS(poly))
ms$console()
// javascript follows in the V8 console
mapshaper.applyCommands("-simplify 0.5 visvalingam", poly, cb); // null
typeof(cb) // function
typeof(poly) // object
JSON.stringify(poly) // looks ok??
exit
## end of javascrpt
