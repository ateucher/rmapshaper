poly <- basic_poly()

poly_attr <- basic_poly(attr = TRUE)

points <- basic_points()
poly_spdf <- GeoJSON_to_sp(poly)
poly_sp <- as(poly_spdf, "SpatialPolygons")

points_spdf <- GeoJSON_to_sp(points)
points_sp <- as(points_spdf, "SpatialPoints")

test_that("ms_dissolve.geojson works", {
  out_poly <- ms_dissolve(poly)
  expect_s3_class(out_poly, "geojson")
  expect_equal(nrow(geojson_sf(out_poly)), 1)
  expect_snapshot_value(out_poly, style = "json2")

  out_points <- ms_dissolve(points)
  expect_s3_class(out_points, "geojson")
  expect_snapshot_value(out_points, style = "json2")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_dissolve(points, sys = TRUE), "geojson")
})

test_that("ms_dissolve.geojson errors correctly", {
  expect_error(ms_dissolve('{foo: "bar"}'), "Input is not valid geojson")
})

test_that("ms_dissolve.character works", {
  out_poly <- ms_dissolve(unclass(poly))
  expect_s3_class(out_poly, "geojson")
  expect_equal(nrow(geojson_sf(out_poly)), 1)
  expect_snapshot_value(out_poly, style = "json2")
  out_points <- ms_dissolve(unclass(points))
  expect_s3_class(out_points, "geojson")
  expect_snapshot_value(out_points, style = "json2")

})

test_that("ms_dissolve.SpatialPolygons works", {
  out_poly <- ms_dissolve(poly_spdf)
  expect_s4_class(out_poly, "SpatialPolygonsDataFrame")
  expect_equal(length(out_poly@polygons), 1)

  out_points <- ms_dissolve(points_spdf)
  expect_s4_class(out_points, "SpatialPointsDataFrame")
  expect_equal(nrow(out_points@coords), 1)

  out_poly <- ms_dissolve(poly_sp)
  expect_s4_class(out_poly, "SpatialPolygons")
  expect_equal(length(out_poly@polygons), 1)

  out_points <- ms_dissolve(points_sp)
  expect_s4_class(out_points, "SpatialPoints")
  expect_equal(nrow(out_points@coords), 1)

  skip_if_not(has_sys_mapshaper())
  expect_s4_class(ms_dissolve(poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("copy_fields and sum_fields works", {
  expect_snapshot_value(ms_dissolve(poly_attr, copy_fields = c("a", "b")),
                        style = "json2")

  expect_snapshot_value(ms_dissolve(poly_attr, sum_fields = c("a", "b")),
                        style = "json2")
})

## sf classes
points_sf <- st_as_sf(points_spdf)
poly_sf <- st_as_sf(poly_spdf)

test_that("ms_dissolve.sf works with points", {
  expect_s3_class(ms_dissolve(points_sf), "sf")
  expect_s3_class(ms_dissolve(st_geometry(points_sf)), "sfc")
})

test_that("ms_dissolve.sf works with polygons", {
  expect_s3_class(ms_dissolve(poly_sf), "sf")
  expect_s3_class(ms_dissolve(st_geometry(poly_sf)), "sfc")
  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_dissolve(poly_sf, sys = TRUE), "sf")
})

test_that("weight argument works", {
  # Don't test this as the V8 error throws a warning
  expect_warning(ms_dissolve(points, weight = "w"), "The command returned an empty response.")
  expect_error(ms_dissolve(points_sf, weight = "w"), "specified 'weight' column not present in input data")
  expect_gt(sum(sf::st_coordinates(ms_dissolve(points_sf, weight = "foo"))),
            sum(sf::st_coordinates(ms_dissolve(points_sf))))
  expect_gt(sum(sp::coordinates(ms_dissolve(points_spdf, weight = "foo"))),
            sum(sp::coordinates(ms_dissolve(points_spdf))))
})
