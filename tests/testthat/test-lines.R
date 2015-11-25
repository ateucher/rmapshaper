context("ms_lines")
library(geojsonio)

poly_geo_json <- structure('{"type":"FeatureCollection",
  "features":[
 {"type":"Feature",
 "properties":{"foo": "a"},
 "geometry":{"type":"Polygon","coordinates":[[
 [102,2],[102,3],[103,3],[103,2],[102,2]
 ]]}}
 ,{"type":"Feature",
 "properties":{"foo": "b"},
 "geometry":{"type":"Polygon","coordinates":[[
 [103,3],[104,3],[104,2],[103,2],[103,3]
 ]]}}]}', class = c("json", "geo_json"))

poly_geo_list <- geojson_list(poly_geo_json)

poly_spdf <- geojson_sp(poly_geo_json)

test_that("ms_lines works with all classes", {
  expected_json <- ms_lines(poly_geo_json)

  expect_equal(ms_lines(poly_geo_json), expected_json)
  expect_equal(ms_lines(poly_geo_list), geojson_list(expected_json))
  expect_equal(ms_lines(poly_spdf), geojson_sp(expected_json))
})
