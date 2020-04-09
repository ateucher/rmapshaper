context("ms_explode")
suppressPackageStartupMessages({
  library("geojsonio")
  library("sf", quietly = TRUE)
})

js <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{
"type": "MultiPolygon",
"coordinates": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0],
[102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0],
[100.0, 0.0]]]]
}}]}', class = c("json", "geo_json"))

multi_line <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{
"type": "MultiLineString",
"coordinates": [[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0]],
[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0]]]
}}]}', class = c("json", "geo_json"))

multi_point <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type": "MultiPoint","coordinates": [ [100.0, 0.0], [101.0, 1.0] ]}}]}', class = c("json", "geo_json"))

test_that("ms_explode.geo_json works", {
  out <- ms_explode(js)
  expect_is(out, "geo_json")
  expect_equal(nrow(geojson_sf(out)), 2)
  expect_equivalent_json(out, "{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}")
  skip_if_not(has_sys_mapshaper())
  expect_is(ms_explode(js, sys = TRUE), "geo_json")
})

test_that("ms_explode.geo_json errors correctly", {
  expect_error(ms_explode('{foo: "bar"}'), "Input is not valid geojson")
})

test_that("ms_explode.character works", {
  out <- ms_explode(unclass(js))
  expect_is(out, "geo_json")
  expect_equal(nrow(geojson_sf(out)), 2)
  expect_equivalent_json(out, "{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}")
})

test_that("ms_explode.SpatialPolygonsDataFrame works", {
  spdf <- geojsonio::geojson_sp(js)
  out <- ms_explode(spdf, force_FC = TRUE)
  expect_is(out, "SpatialPolygonsDataFrame")
  # Temporarily remove due to bug in GDAL 2.1.0
  expect_equal(length(out@polygons), 2)
  sp_dis <- sp::disaggregate(spdf)
  # Temporarily remove due to bug in GDAL 2.1.0
  expect_equivalent(lapply(out@polygons, function(x) x@Polygons[[1]]@coords),
              lapply(sp_dis@polygons, function(x) x@Polygons[[1]]@coords))
  skip_if_not(has_sys_mapshaper())
  expect_is(ms_explode(spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("ms_explode works with lines", {
  multi_line_exploded <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"LineString","coordinates":[[102,2],[103,2],[103,3],[102,3]]},"properties":{"rmapshaperid":0}},
{"type":"Feature","geometry":{"type":"LineString","coordinates":[[100,0],[101,0],[101,1],[100,1]]},"properties":{"rmapshaperid":1}}
]} ', class = c("json", "geo_json"))

  expect_equivalent_json(ms_explode(multi_line), multi_line_exploded)

  sp_lines <- geojsonio::geojson_sp(multi_line_exploded)
  out <- ms_explode(sp_lines)
  out_disagg <- sp::disaggregate(sp_lines)
  expect_equivalent(lapply(out@lines, function(x) x@Lines[[1]]@coords),
               lapply(out_disagg@lines, function(x) x@Lines[[1]]@coords))
  skip_if_not(has_sys_mapshaper())
  expect_is(ms_explode(sp_lines, sys = TRUE), "SpatialLinesDataFrame")
})

test_that("ms_explode works with points", {
  multi_point_exploded <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[100,0]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[101,1]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))
  expect_equivalent_json(ms_explode(multi_point), multi_point_exploded)
})


test_that("ms_explode works with sf", {
  multi_point <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"a":"b"},"geometry":{"type": "MultiPoint","coordinates": [ [100.0, 0.0], [101.0, 1.0] ]}}]}'
  mp_sf <- read_sf(multi_point)
  out_sf <- ms_explode(mp_sf)
  expect_is(out_sf, "sf")
  expect_equal(nrow(out_sf), 2)
  expect_is(st_geometry(out_sf), "sfc_POINT")

  mp_sfc <- st_geometry(mp_sf)
  out_sfc <- ms_explode(mp_sfc)
  expect_is(out_sfc, "sfc_POINT")
  expect_equal(length(out_sfc), 2)

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_explode(mp_sf, sys = TRUE), "sf")
})
