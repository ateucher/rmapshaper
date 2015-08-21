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
  return data;
}"

file <- system.file("examples", "california.geojson", package = "geojsonio")
test_data <- as.json(geojson_read(file))

test_cmd <- "-simplify 0.05 visvalingam"

ms$assign("cb", JS(callback))
ms$call("mapshaper.applyCommands", test_cmd, test_data, "cb")
