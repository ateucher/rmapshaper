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
 "properties":{"foo": "a"},
 "geometry":{"type":"Polygon","coordinates":[[
 [103,3],[104,3],[104,2],[103,2],[103,3]
 ]]}},
 {"type":"Feature",
 "properties":{"foo": "b"},
 "geometry":{"type":"Polygon","coordinates":[[
 [102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]
 ]]}}]}', class = c("json", "geo_json"))

poly_geo_list <- geojson_list(poly_geo_json)

poly_spdf <- geojson_sp(poly_geo_json)
poly_sp <- as(poly_spdf, "SpatialPolygons")

test_that("ms_lines works with all classes", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"TYPE\":1,\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2],[102,3],[103,3]]},\"properties\":{\"TYPE\":0,\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2],[103,2]]},\"properties\":{\"TYPE\":0,\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]]},\"properties\":{\"TYPE\":0,\"rmapshaperid\":3}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  "geo_json"))

  expect_equal(ms_lines(unclass(poly_geo_json)), expected_json)
  expect_equal(ms_lines(poly_geo_json), expected_json)
  expect_equal(ms_lines(poly_geo_list), geojson_list(expected_json))
  expect_equal(ms_lines(poly_spdf), geojson_sp(expected_json))
  expect_equal(ms_lines(poly_sp), as(geojson_sp(expected_json), "SpatialLines"))
})

test_that("ms_lines works with fields specified", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"TYPE\":2,\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2],[102,3],[103,3]]},\"properties\":{\"TYPE\":0,\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2],[103,2]]},\"properties\":{\"TYPE\":0,\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]]},\"properties\":{\"TYPE\":0,\"rmapshaperid\":3}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  "geo_json"))

  expect_equal(ms_lines(poly_geo_json, "foo"), expected_json)
  expect_equal(ms_lines(poly_geo_list, "foo"), geojson_list(expected_json))
  expect_equal(ms_lines(poly_spdf, "foo"), geojson_sp(expected_json))
})

test_that("ms_lines errors correctly", {
  expect_error(ms_lines('{foo: "bar"}'), "Input is not valid geojson")
  expect_error(ms_lines(poly_geo_json, "bar"), "Unknown data field: bar")
  expect_error(ms_lines(poly_spdf, "bar"), "not all fields specified exist in input data")
  expect_error(ms_lines(poly_geo_json, 1), "fields must be a character vector")
  expect_error(ms_lines(poly_geo_json, force_FC = "true"), "force_FC must be TRUE or FALSE")
})
