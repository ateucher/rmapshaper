context("ms_innerlines")
library(geojsonio)

poly_geo_json <- structure('{"type":"FeatureCollection",
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
]]}}]}', class = c("json", "geo_json"))

poly_geo_list <- geojson_list(poly_geo_json)

poly_spdf <- geojson_sp(poly_geo_json)
poly_sp <- as(poly_spdf, "SpatialPolygons")

test_that("ms_innerlines works with all classes", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":{\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":{\"rmapshaperid\":3}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    "geo_json"))

  expect_equal(ms_innerlines(unclass(poly_geo_json)), expected_json)
  expect_equal(ms_innerlines(poly_geo_json), expected_json)
  expect_equal(ms_innerlines(poly_geo_list), geojson_list(expected_json))
  expect_equal(ms_innerlines(poly_spdf), geojson_sp(expected_json))
  expect_equal(ms_innerlines(poly_sp), as(geojson_sp(expected_json), "SpatialLines"))
})

test_that("ms_innerlines errors correctly", {
  expect_error(ms_innerlines("foo"), "Input is not valid geojson")
  expect_error(ms_innerlines(poly_geo_json, force_FC = "true"), "force_FC must be TRUE or FALSE")
  expect_error(ms_innerlines(ms_lines(poly_geo_json)), "Command requires a polygon layer")
})
