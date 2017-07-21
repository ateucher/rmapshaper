context("ms_filter_fields")
suppressPackageStartupMessages(library("geojsonio"))

poly <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\": 1, \"b\":2, \"c\": 3},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}}]}",
class = c("json", "geo_json"))

pts <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\":1,\"b\":2,\"c\":3},
\"geometry\":{\"type\":\"Point\",
\"coordinates\":[103,3]}}]}", class = c("json", "geo_json"))

lines <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\":1,\"b\":2,\"c\":3},
\"geometry\":{\"type\":\"LineString\",
\"coordinates\":[[102,2],[102,4],[104,4],[104,2],[102,2]]}}]}",
class = c("json", "geo_json"))

test_that("ms_filter_fields works with polygons", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]},\"properties\":{\"a\":1,\"b\":2}}\n]}", class = c("json",
                                                                                                                                                                                                                                                     "geo_json"))
  expect_equal(ms_filter_fields(poly, c("a", "b")), expected_out)
  expect_equal(ms_filter_fields(unclass(poly), c("a", "b")), expected_out)
  expect_equal(ms_filter_fields(geojson_list(poly), c("a", "b")), geojson_list(expected_out))
  out_sp <- ms_filter_fields(geojson_sp(poly), c("a", "b"))
  expect_is(out_sp, "SpatialPolygonsDataFrame")
  expect_equal(out_sp@data, data.frame(a = 1, b = 2, row.names = 0L))
})

test_that("ms_filter_fields works with points", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[103,3]},\"properties\":{\"a\":1,\"b\":2}}\n]}", class = c("json",
                                                                                                                                                                                                               "geo_json"))
  expect_equal(ms_filter_fields(pts, c("a", "b")), expected_out)
  expect_equal(ms_filter_fields(geojson_list(pts), c("a", "b")), geojson_list(expected_out))
  out_sp <- ms_filter_fields(geojson_sp(pts), c("a", "b"))
  expect_is(out_sp, "SpatialPointsDataFrame")
  expect_equal(out_sp@data, data.frame(a = 1, b = 2))
})

test_that("ms_filter_fields works with lines", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102,2],[102,4],[104,4],[104,2],[102,2]]},\"properties\":{\"a\":1,\"b\":2}}\n]}", class = c("json",
                                                                                                                                                                                                                                                      "geo_json"))
  expect_equal(ms_filter_fields(lines, c("a", "b")), expected_out)
  expect_equal(ms_filter_fields(geojson_list(lines), c("a", "b")), geojson_list(expected_out))
  out_sp <- ms_filter_fields(geojson_sp(lines), c("a", "b"))
  expect_is(out_sp, "SpatialLinesDataFrame")
  expect_equal(out_sp@data, data.frame(a = 1, b = 2, row.names = 0L))
})

test_that("ms_filter_fields fails correctly", {
  expect_error(ms_filter_fields('{foo: "bar"}', "a"), "Input is not valid geojson")
  expect_error(ms_filter_fields(poly, "d"), "Table is missing one or more fields")
  expect_error(ms_filter_fields(geojson_sp(poly), "d"), "Not all named fields exist in input data")
  expect_error(ms_filter_fields(poly, 1), "fields must be a character vector")
})

if (suppressPackageStartupMessages(require("sf", quietly = TRUE))) {
  test_that("ms_filter_fields works with sf", {
    lines_sf <- read_sf(lines)
    out_sf <- ms_filter_fields(lines_sf, c("a", "b"))
    expect_is(out_sf, "sf")
    expect_equal(names(out_sf), c("a", "b", "geometry"))
    expect_error(ms_filter_fields(lines_sf, "d", "Not all fields are in input"))
  })
}