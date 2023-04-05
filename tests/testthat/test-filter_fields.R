pts <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\":1,\"b\":2,\"c\":3},
\"geometry\":{\"type\":\"Point\",
\"coordinates\":[103,3]}}]}", class = c("geojson", "json"))

lines <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\":1,\"b\":2,\"c\":3},
\"geometry\":{\"type\":\"LineString\",
\"coordinates\":[[102,2],[102,4],[104,4],[104,2],[102,2]]}}]}",
                   class = c("geojson", "json"))

test_that("ms_filter_fields works with polygons", {
  poly <- basic_poly(attr = TRUE)

  expect_s3_class(ms_filter_fields(poly, "a"), "geojson")
  expect_s3_class(ms_filter_fields(unclass(poly), c("a", "b")), "geojson")
  expect_snapshot_value(ms_filter_fields(poly, "a"), style = "json2")
  out_sp <- ms_filter_fields(GeoJSON_to_sp(poly), c("a", "b"))
  expect_s4_class(out_sp, "SpatialPolygonsDataFrame")
  expect_equal(out_sp@data, data.frame(a = c(1,5), b = c(2,3), row.names = 1:2))

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_filter_fields(poly, "a", sys = TRUE), "geojson")
  expect_s3_class(ms_filter_fields(GeoJSON_to_sf(poly), c("a", "b"), sys = TRUE), "sf")
})

test_that("ms_filter_fields works with points", {
  pts <- basic_points()

  expect_s3_class(ms_filter_fields(pts, c("x", "y")), "geojson")
  expect_snapshot_value(ms_filter_fields(pts, c("x", "y")), style = "json2")
  out_sp <- ms_filter_fields(GeoJSON_to_sp(pts), "x")
  expect_s4_class(out_sp, "SpatialPointsDataFrame")
  expect_equal(out_sp@data, data.frame(x = c(-78,-71,135)))
})

test_that("ms_filter_fields works with lines", {
  lines <- basic_lines()

  expect_s3_class(ms_filter_fields(lines, c("a", "b")), "geojson")
  expect_snapshot_value(ms_filter_fields(lines, c("a", "b")), style = "json2")
  out_sp <- ms_filter_fields(GeoJSON_to_sp(lines), c("a", "b"))
  expect_s4_class(out_sp, "SpatialLinesDataFrame")
  expect_equal(out_sp@data, data.frame(a = 1, b = 2, row.names = 1L))
})

test_that("ms_filter_fields fails correctly", {
  expect_error(ms_filter_fields('{foo: "bar"}', "a"), "Input is not valid geojson")
  poly <- basic_poly(attr = TRUE)
  expect_warning(ms_filter_fields(poly, "d"), "The command returned an empty response")
  expect_error(ms_filter_fields(GeoJSON_to_sp(poly), "d"), "Not all named fields exist in input data")
  expect_error(ms_filter_fields(poly, 1), "fields must be a character vector")
})

test_that("ms_filter_fields works with sf", {
  lines <- basic_lines()

  lines_sf <- read_sf(unclass(lines))
  out_sf <- ms_filter_fields(lines_sf, c("a", "b"))
  expect_s3_class(out_sf, "sf")
  expect_equal(names(out_sf), c("a", "b", "geometry"))
  expect_error(ms_filter_fields(lines_sf, "d"), "Not all fields are in input")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_filter_fields(lines_sf, c("a", "b"), sys = TRUE), "sf")
})
