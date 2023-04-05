islands_poly <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",\"properties\":{},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}},
{\"type\":\"Feature\",\"properties\":{},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[100,2],[98,4],[101.5,4],[100,2]]]}},
{\"type\":\"Feature\",\"properties\":{},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]}}]}",
                  class = c("geojson", "json"))

islands_poly_spdf <- GeoJSON_to_sp(islands_poly)
islands_poly_sp <- as(islands_poly_spdf, "SpatialPolygons")


islands_poly_sf <- st_as_sf(islands_poly_spdf)
islands_poly_sfc <- st_geometry(islands_poly_sf)

test_that("ms_filter_islands works with min_area", {
  expect_s3_class(ms_filter_islands(islands_poly, min_area = 12391399903), "geojson")
  expect_s3_class(ms_filter_islands(unclass(islands_poly), min_area = 12391399903), "geojson")

  expect_snapshot_value(ms_filter_islands(islands_poly, min_area = 12391399903), style = "json2")

  out_spdf <- ms_filter_islands(islands_poly_spdf, min_area = 12391399903)
  out_sp <- ms_filter_islands(islands_poly_sp, min_area = 12391399903)
  expect_equal(out_spdf@polygons, out_sp@polygons)
  expect_equal(length(out_spdf@polygons), 2)
  expect_equal(out_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(102, 102, 104, 104, 102, 2, 4, 4, 2, 2), .Dim = c(5L, 2L)))
  expect_equal(out_spdf@polygons[[2]]@Polygons[[1]]@coords,
               structure(c(100, 98, 101.5, 100, 2, 4, 4, 2), .Dim = c(4L, 2L)))

  out_sf <- ms_filter_islands(islands_poly_sf, min_area = 12391399903)
  out_sfc <- ms_filter_islands(islands_poly_sfc, min_area = 12391399903)
  expect_equal(length(out_sfc), 2)
  expect_equal(st_geometry(out_sf), out_sfc)
})

test_that("ms_filter_islands works with min_vertoces", {
  expect_s3_class(ms_filter_islands(islands_poly, min_vertices = 4), "geojson")
  expect_snapshot_value(ms_filter_islands(islands_poly, min_vertices = 4), style = "json2")

  expect_s3_class(ms_filter_islands(unclass(islands_poly), min_vertices = 4), "geojson")
  out_spdf <- ms_filter_islands(islands_poly_spdf, min_vertices = 4)
  expect_equal(length(out_spdf@polygons[[1]]@Polygons), 1)
  expect_equal(out_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(102, 102, 104, 104, 102, 2, 4, 4, 2, 2), .Dim = c(5L, 2L)))

  out_sfc <- ms_filter_islands(islands_poly_sfc, min_vertices = 4)
  expect_equal(length(out_sfc), 2)
})

test_that("ms_filter_islands works drop_null_geometries = FALSE", {
  expect_s3_class(ms_filter_islands(islands_poly, min_area = 43310462718, drop_null_geometries = FALSE), "geojson")
  expect_snapshot_value(ms_filter_islands(islands_poly, min_area = 43310462718, drop_null_geometries = FALSE), style = "json2")

  expect_s3_class(ms_filter_islands(unclass(islands_poly), min_area = 43310462718, drop_null_geometries = FALSE), "geojson")
  out_spdf <- ms_filter_islands(islands_poly_spdf, min_area = 43310462718, drop_null_geometries = FALSE)
  expect_equal(length(out_spdf@polygons[[1]]@Polygons), 1)
  expect_equal(out_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(102, 102, 104, 104, 102, 2, 4, 4, 2, 2), .Dim = c(5L, 2L)))
})

test_that("specifying min_vertices and min_area works", {
  skip("possible bug in mapshaper https://github.com/mbloch/mapshaper/issues/487")
  expect_snapshot_value(ms_filter_islands(geojson_list(islands_poly), min_area = 12391399902, min_vertices = 4),
                        style = "json2")
})

test_that("ms_filter_islands fails correctly", {
  expect_error(ms_filter_islands(islands_poly, min_area = "foo"), "min_area must be numeric")
  expect_error(ms_filter_islands(islands_poly, min_vertices = "foo"), "min_vertices must be numeric")
  expect_error(ms_filter_islands(islands_poly, drop_null_geometries = "foo"), "drop_null_geometries must be TRUE or FALSE")
  expect_error(ms_filter_islands(islands_poly, force_FC = "foo"), "force_FC must be TRUE or FALSE")
})

test_that("ms_filter_islands works with sys = TRUE", {
  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_filter_islands(islands_poly, min_area = 12391399902, sys = TRUE), "geojson")
  expect_snapshot_value(ms_filter_islands(islands_poly, min_area = 12391399902, sys = TRUE), style = "json2")
  expect_s4_class(ms_filter_islands(islands_poly_spdf, min_area = 12391399902, sys = TRUE), "SpatialPolygonsDataFrame")
  expect_s3_class(ms_filter_islands(islands_poly_sf, min_area = 12391399902, sys = TRUE), "sf")
})
