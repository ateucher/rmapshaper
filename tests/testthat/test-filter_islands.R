context("ms_filter_islands")
suppressPackageStartupMessages({
  library("geojsonio")
  library("sf", quietly = TRUE)
})

poly <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",\"properties\":{},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}},
{\"type\":\"Feature\",\"properties\":{},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[100,2],[98,4],[101.5,4],[100,2]]]}},
{\"type\":\"Feature\",\"properties\":{},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]}}]}",
                  class = c("json", "geo_json"))

poly_spdf <- geojson_sp(poly)
poly_sp <- as(poly_spdf, "SpatialPolygons")


poly_sf <- st_as_sf(poly_spdf)
poly_sfc <- st_geometry(poly_sf)

test_that("ms_filter_islands works with min_area", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,2],[98,4],[101.5,4],[100,2]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))

  expect_is(ms_filter_islands(poly, min_area = 12391399903), "geo_json")
  expect_is(ms_filter_islands(unclass(poly), min_area = 12391399903), "geo_json")
  expect_equal(ms_filter_islands(geojson_list(poly), min_area = 12391399903),
               geojson_list(expected_json))
  out_spdf <- ms_filter_islands(poly_spdf, min_area = 12391399903)
  out_sp <- ms_filter_islands(poly_sp, min_area = 12391399903)
  expect_equal(out_spdf@polygons, out_sp@polygons)
  expect_equal(length(out_spdf@polygons), 2)
  expect_equal(out_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(102, 102, 104, 104, 102, 2, 4, 4, 2, 2), .Dim = c(5L, 2L)))
  expect_equal(out_spdf@polygons[[2]]@Polygons[[1]]@coords,
               structure(c(100, 98, 101.5, 100, 2, 4, 4, 2), .Dim = c(4L, 2L)))

  out_sf <- ms_filter_islands(poly_sf, min_area = 12391399903)
  out_sfc <- ms_filter_islands(poly_sfc, min_area = 12391399903)
  expect_equal(length(out_sfc), 2)
  expect_equivalent(st_geometry(out_sf), out_sfc)

})

test_that("ms_filter_islands works with min_vertoces", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))
  expect_is(ms_filter_islands(poly, min_vertices = 4), "geo_json")
  expect_is(ms_filter_islands(unclass(poly), min_vertices = 4), "geo_json")
  expect_equal(ms_filter_islands(geojson_list(poly), min_vertices = 4),
               geojson_list(expected_json))
  out_spdf <- ms_filter_islands(poly_spdf, min_vertices = 4)
  expect_equal(length(out_spdf@polygons[[1]]@Polygons), 1)
  expect_equal(out_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(102, 102, 104, 104, 102, 2, 4, 4, 2, 2), .Dim = c(5L, 2L)))

  out_sfc <- ms_filter_islands(poly_sfc, min_vertices = 4)
  expect_equal(length(out_sfc), 2)
})

test_that("ms_filter_islands works drop_null_geometries = FALSE", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":null,\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":null,\"properties\":{\"rmapshaperid\":2}}\n]}", class = c("json", "geo_json"))
  expect_is(ms_filter_islands(poly, min_area = 43310462718, drop_null_geometries = FALSE), "geo_json")
  expect_is(ms_filter_islands(unclass(poly), min_area = 43310462718, drop_null_geometries = FALSE), "geo_json")
  expect_equal(ms_filter_islands(geojson_list(poly), min_area = 43310462718, drop_null_geometries = FALSE),
               geojson_list(expected_json))
  out_spdf <- ms_filter_islands(poly_spdf, min_area = 43310462718, drop_null_geometries = FALSE)
  expect_equal(length(out_spdf@polygons[[1]]@Polygons), 1)
  expect_equal(out_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(102, 102, 104, 104, 102, 2, 4, 4, 2, 2), .Dim = c(5L, 2L)))
})

test_that("specifying min_vertices and min_area works", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))
  expect_equal(ms_filter_islands(geojson_list(poly), min_area = 12391399902, min_vertices = 4), geojson_list(expected_json))
})

test_that("ms_filter_islands fails correctly", {
  expect_error(ms_filter_islands(poly, min_area = "foo"), "min_area must be numeric")
  expect_error(ms_filter_islands(poly, min_vertices = "foo"), "min_vertices must be numeric")
  expect_error(ms_filter_islands(poly, drop_null_geometries = "foo"), "drop_null_geometries must be TRUE or FALSE")
  expect_error(ms_filter_islands(poly, force_FC = "foo"), "force_FC must be TRUE or FALSE")
})

test_that("ms_filter_islands works with sys = TRUE", {
  skip_if_not(has_sys_mapshaper())
  expect_is(ms_filter_islands(poly, sys = TRUE), "geo_json")
  expect_is(ms_filter_islands(geojson_list(poly), sys = TRUE), "geo_list")
  expect_is(ms_filter_islands(poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
  expect_is(ms_filter_islands(poly_sf, sys = TRUE), "sf")
})
