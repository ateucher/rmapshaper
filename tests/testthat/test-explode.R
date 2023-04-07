multi_poly <- structure(
  '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{
"type": "MultiPolygon",
"coordinates": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0],
[102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0],
[100.0, 0.0]]]]
}}]}',
class = c("geojson", "json")
)

multi_line <- structure(
  '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{
"type": "MultiLineString",
"coordinates": [[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0]],
[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0]]]
}}]}',
class = c("geojson", "json")
)

multi_point <- structure(
  '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{
  "type": "MultiPoint","coordinates": [ [100.0, 0.0], [101.0, 1.0] ]}}]}',
  class = c("geojson", "json")
)

test_that("ms_explode.geojson works", {
  out <- ms_explode(multi_poly)
  expect_s3_class(out, "geojson")
  expect_equal(nrow(geojson_sf(out)), 2)
  expect_snapshot_value(out, style = "json2")
  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_explode(multi_poly, sys = TRUE), "geojson")
})

test_that("ms_explode.geojson errors correctly", {
  expect_error(ms_explode('{foo: "bar"}'), "Input is not valid geojson")
})

test_that("ms_explode.character works", {
  out <- ms_explode(unclass(multi_poly))
  expect_s3_class(out, "geojson")
  expect_equal(nrow(geojson_sf(out)), 2)
  expect_snapshot_value(out, style = "json2")
})

test_that("ms_explode.SpatialPolygonsDataFrame works", {
  spdf <- GeoJSON_to_sp(multi_poly)
  out <- ms_explode(spdf)
  expect_s4_class(out, "SpatialPolygonsDataFrame")
  # Temporarily remove due to bug in GDAL 2.1.0
  expect_equal(length(out@polygons), 2)
  skip_if_not(has_sys_mapshaper())
  expect_s4_class(ms_explode(spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("ms_explode works with lines", {
  expect_snapshot_value(ms_explode(multi_line), style = "json2")

  sp_lines <- GeoJSON_to_sp(multi_line)
  out <- ms_explode(sp_lines)
  out_disagg <- sp::disaggregate(sp_lines)
  expect_equivalent(lapply(out@lines, function(x) x@Lines[[1]]@coords),
               lapply(out_disagg@lines, function(x) x@Lines[[1]]@coords))
  skip_if_not(has_sys_mapshaper())
  expect_s4_class(ms_explode(sp_lines, sys = TRUE), "SpatialLinesDataFrame")
})

test_that("ms_explode works with points", {
  expect_snapshot_value(ms_explode(multi_point), style = "json2")
})


test_that("ms_explode works with sf", {
  mp_sf <- read_sf(multi_point)
  out_sf <- ms_explode(mp_sf)
  expect_s3_class(out_sf, "sf")
  expect_equal(nrow(out_sf), 2)
  expect_s3_class(st_geometry(out_sf), "sfc_POINT")

  mp_sfc <- st_geometry(mp_sf)
  out_sfc <- ms_explode(mp_sfc)
  expect_s3_class(out_sfc, "sfc_POINT")
  expect_equal(length(out_sfc), 2)

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_explode(mp_sf, sys = TRUE), "sf")
})
