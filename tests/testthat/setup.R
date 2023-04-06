suppressPackageStartupMessages({
  library("jsonify", quietly = TRUE)
  library("geojsonsf")
  library("sp")
  library("sf", quietly = TRUE)
  library("jsonlite")
})

withr::local_options(
  "rgdal_show_exportToProj4_warnings" = "none",
  "mapshaper.sys_quiet" = TRUE
)

## Objects for testing

basic_poly <- function(attr = FALSE) {
  structure(
    paste0('{"type":"FeatureCollection",
  "features":[
  {"type":"Feature",',
  ifelse(attr, '"properties":{"a": 1, "b": 2},', '"properties":{},'),
  '"geometry":{"type":"Polygon","coordinates":[[
  [102,2],[102,3],[103,3],[103,2],[102,2]
  ]]}}
  ,{"type":"Feature",',
  ifelse(attr, '"properties":{"a": 5, "b": 3},', '"properties":{},'),
  '"geometry":{"type":"Polygon","coordinates":[[
  [100,0],[100,1],[101,1],[101,0],[100,0]
  ]]}}]}'),
  class = c("geojson", "json")
  )
}

basic_points <- function() {
  structure(
    '{"type":"FeatureCollection",
    "features":[{
    "type":"Feature",
    "geometry":{"type":"Point","coordinates":[-78.41,-53.95]},
    "properties":{"x":-78,"y":-53,"foo":0}},{
    "type":"Feature",
    "geometry":{"type":"Point","coordinates":[-70.86,65.19]},
    "properties":{"x":-71,"y":65,"foo":1}},{
    "type":"Feature",
    "geometry":{"type":"Point","coordinates":[135.65,63.10]},
    "properties":{"x":135,"y":65,"foo":2}}]}',
    class = c("geojson", "json")
  )
}

basic_lines <- function() {
  structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\":1,\"b\":2,\"c\":3},
\"geometry\":{\"type\":\"LineString\",
\"coordinates\":[[102,2],[102,4],[104,4],[104,2],[102,2]]}}]}",
class = c("geojson", "json"))
}

ce_poly <- structure('{"type":"FeatureCollection","features":[{
"type": "Feature",
"properties": {},
"geometry": {
"type": "Polygon",
"coordinates": [
[
[53, -42],
[57, -42],
[57, -47],
[53, -47],
[53, -42]
]
]
}}]
}', class = c("geojson", "json"))

ce_line <- structure('{"type":"FeatureCollection","features":[
{ "type": "Feature",
"geometry": {
"type": "LineString",
"coordinates": [
[60, -37], [52, -42]
]
},
"properties": {}
}]
}', class = c("geojson", "json"))

ce_points <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[53,-42]},"properties":{}},{"type":"Feature","geometry":{"type":"Point","coordinates":[57,-42]},"properties":{}}]}', class = c("geojson", "json"))

ce_inner_poly <- structure('{
"type": "Feature",
"properties": {},
"geometry": {
"type": "Polygon",
"coordinates": [
[
[51, -40],
[55, -40],
[55, -45],
[51, -45],
[51, -40]
]
]
}
}', class = c("geojson", "json"))

ce_poly_spdf <- GeoJSON_to_sp(ce_poly)
ce_poly_sp <- as(ce_poly_spdf, "SpatialPolygons")

ce_line_spdf <- GeoJSON_to_sp(ce_line)
ce_line_sp <- as(ce_line_spdf, "SpatialLines")

ce_points_spdf <- GeoJSON_to_sp(ce_points)
ce_points_sp <- as(ce_points_spdf, "SpatialPoints")

ce_inner_poly_spdf <- GeoJSON_to_sp(ce_inner_poly)

ce_poly_sf <- sf::st_as_sf(ce_poly_spdf)
ce_poly_sfc <- sf::st_as_sfc(ce_poly_sp)
ce_lines_sf <- sf::st_as_sf(ce_line_spdf)
ce_points_sf <- sf::st_as_sf(ce_points_spdf)

ce_inner_poly_sf <- sf::read_sf(unclass(ce_inner_poly))

innerlines_poly <- structure('{"type":"FeatureCollection",
  "features":[
{"type":"Feature",
"properties":{"foo": "a"},
"geometry":{"type":"Polygon","coordinates":[[
[102,2],[102,3],[103,3],[103,2],[102,2]
]]}}
,{"type":"Feature",
"properties":{"foo": "a"},
"geometry":{"type":"Polygon","coordinates":[[
[103,3],[104,3],[104,2],[103,2],[103,3]
]]}},
{"type":"Feature",
"properties":{"foo": "b"},
"geometry":{"type":"Polygon","coordinates":[[
[102,1],[102,2],[103,2],[103,1],[102,1]
]]}},
{"type":"Feature",
"properties":{"foo": "b"},
"geometry":{"type":"Polygon","coordinates":[[
[103,1],[103,2],[104,2],[104,1],[103,1]
]]}}]}', class = c("geojson", "json"))

innerlines_poly_spdf <- GeoJSON_to_sp(innerlines_poly)
innerlines_poly_sp <- as(innerlines_poly_spdf, "SpatialPolygons")

innerlines_poly_sf <- read_sf(unclass(innerlines_poly))
innerlines_poly_sfc <- st_geometry(innerlines_poly_sf)
