context("ms_innerlines")
suppressPackageStartupMessages({
  library("geojsonio")
  library("sf", quietly = TRUE)
})

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


poly_sf <- read_sf(unclass(poly_geo_json))
poly_sfc <- st_geometry(poly_sf)


test_that("ms_innerlines works with all classes", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":{\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":{\"rmapshaperid\":3}}\n]}", class = c("json", "geo_json"))
  expected_sp <- as(geojson_sp(expected_json), "SpatialLines")

  expect_is(ms_innerlines(unclass(poly_geo_json)), "geo_json")
  expect_is(ms_innerlines(poly_geo_json), "geo_json")
  expect_equivalent(ms_innerlines(poly_geo_list), geojson_list(expected_json))
  expect_equivalent(ms_innerlines(poly_spdf), expected_sp)
  expect_equivalent(ms_innerlines(poly_sp), expected_sp)

  expected_sf <- st_geometry(read_sf(unclass(expected_json)))
  expect_equivalent(ms_innerlines(poly_sf), expected_sf)
  expect_equivalent(ms_innerlines(poly_sfc), expected_sf)
})

test_that("ms_innerlines errors correctly", {
  expect_error(ms_innerlines('{foo: "bar"}'), "Input is not valid geojson")
  expect_error(ms_innerlines(poly_geo_json, force_FC = "true"), "force_FC must be TRUE or FALSE")
  # Don't test this as the V8 error throws a warning
  expect_error(ms_innerlines(ms_lines(poly_geo_json)), class = "std::runtime_error")
})

test_that("ms_innerlines works with sys = TRUE", {
  skip_if_not(has_sys_mapshaper())
  expect_is(ms_innerlines(poly_geo_json, sys = TRUE), "geo_json")
  expect_is(ms_innerlines(poly_geo_list, sys = TRUE), "geo_list")
  expect_is(ms_innerlines(poly_spdf, sys = TRUE), "SpatialLines")
  expect_is(ms_innerlines(poly_sf, sys = TRUE), "sfc")
})
