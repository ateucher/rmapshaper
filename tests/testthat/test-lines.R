context("ms_lines")
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
 [102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]
 ]]}}]}', class = c("json", "geo_json"))

poly_geo_list <- geojson_list(poly_geo_json)

poly_spdf <- geojson_sp(poly_geo_json)
poly_sp <- as(poly_spdf, "SpatialPolygons")


poly_sf <- read_sf(unclass(poly_geo_json))
poly_sfc <- st_geometry(poly_sf)


test_that("ms_lines works with all classes", {
  expected_json <- structure(structure("{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2],[102,3],[103,3]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2],[103,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":3}}\n]}", class = c("json", "geo_json")))

  expected_sp <- geojson_sp(expected_json, stringsAsFactors = FALSE)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_is(ms_lines(unclass(poly_geo_json)), "geo_json")
  expect_is(ms_lines(poly_geo_json), "geo_json")
  expect_equal(ms_lines(poly_geo_list), geojson_list(expected_json))
  expect_equal(ms_lines(poly_spdf), expected_sp)
  expect_equal(ms_lines(poly_sp), as(expected_sp, "SpatialLines"))


  expected_sf <- read_sf(unclass(expected_json))
  expected_sf <- expected_sf[, setdiff(names(expected_sf), "rmapshaperid")]
  expected_sfc <- st_geometry(expected_sf)

  expect_equal(st_geometry(ms_lines(poly_sf)), expected_sfc)
  expect_equal(ms_lines(poly_sfc), expected_sfc)
})

test_that("ms_lines works with fields specified", {
  expected_json <- structure("{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"RANK\":2,\"TYPE\":\"inner\",\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2],[102,3],[103,3]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2],[103,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":3}}\n]}", class = c("json", "geo_json"))

  expected_sp <- geojson_sp(expected_json, stringsAsFactors = FALSE)

  expect_is(ms_lines(poly_geo_json, "foo"), "geo_json")
  expect_equal(ms_lines(poly_geo_list, "foo"), geojson_list(expected_json))
  expect_equal(ms_lines(poly_spdf, "foo"),
               expected_sp[, setdiff(names(expected_sp), "rmapshaperid")])

  expect_equal(ms_lines(poly_sf, "foo")$RANK, c(2L,0L,0L,0L))
})

test_that("ms_lines errors correctly", {
  expect_error(ms_lines('{foo: "bar"}'), "Input is not valid geojson")
  expect_error(ms_lines(poly_geo_json, "bar"), "Unknown data field: bar")
  expect_error(ms_lines(poly_spdf, "bar"), "not all fields specified exist in input data")
  expect_error(ms_lines(poly_geo_json, 1), "fields must be a character vector")
  expect_error(ms_lines(poly_geo_json, force_FC = "true"), "force_FC must be TRUE or FALSE")

  expect_error(ms_lines(poly_sfc, "foo"), "Do not specify fields for sfc classes")
})

test_that("ms_innerlines works with sys = TRUE", {
  skip_if_not(has_sys_mapshaper())
  expect_is(ms_lines(poly_geo_json, sys = TRUE), "geo_json")
  expect_is(ms_lines(poly_geo_list, sys = TRUE), "geo_list")
  expect_is(ms_lines(poly_spdf, sys = TRUE), "SpatialLinesDataFrame")
  expect_is(ms_lines(poly_sf, sys = TRUE), "sf")
})
