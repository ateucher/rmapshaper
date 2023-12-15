test_that("ms_union.geojson works", {
  skip_on_old_v8()
  default_union_json <- ms_union(ce_poly, ce_inner_poly)

  expect_s3_class(default_union_json, "geojson")
  expect_snapshot_value(default_union_json, style = "json2")
  expect_true(jsonify::validate_json(default_union_json))

  expect_snapshot_value(
    ms_union(ce_poly, ce_inner_poly, force_FC = FALSE),
    style = "json2"
  )

  skip_if_not(has_sys_mapshaper())
  out_sys <- ms_union(ce_poly, ce_inner_poly, sys = TRUE)
  expect_s3_class(out_sys, "geojson")
  expect_snapshot_value(out_sys, style = "json2")

  out_sys_nofc <- ms_union(ce_poly, ce_inner_poly, sys = TRUE, force_FC = FALSE)
  expect_s3_class(out_sys_nofc, "geojson")
  expect_snapshot_value(out_sys_nofc, style = "json2")
})

test_that("ms_union.character works", {
  skip_on_old_v8()
  default_union_json <- ms_union(unclass(ce_poly), unclass(ce_inner_poly))

  expect_s3_class(default_union_json, "geojson")
  expect_snapshot_value(default_union_json, style = "json2")
  expect_true(jsonify::validate_json(default_union_json))
})

## Spatial Classes
test_that("ms_union.SpatialPolygons works", {
  skip_on_old_v8()
  default_union_spdf <- ms_union(ce_poly_spdf, ce_inner_poly_spdf)

  expect_s4_class(default_union_spdf, "SpatialPolygonsDataFrame")
  expect_equivalent(sapply(default_union_spdf@polygons[[1]]@Polygons, function(x) length(x@coords)), 10)

  default_union_sp <- ms_union(ce_poly_sp, ce_inner_poly_spdf)
  expect_equivalent(as(default_union_spdf, "SpatialPolygons"), default_union_sp)

  skip_if_not(has_sys_mapshaper())
  expect_s4_class(ms_union(ce_poly_spdf, ce_inner_poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

## test sf classes

test_that("union works with sf objects", {
  skip_on_old_v8()
  expect_s3_class(ms_union(ce_poly_sf, ce_inner_poly_sf), "sf")
  expect_equivalent(names(ms_union(ce_poly_sf, ce_inner_poly_sf)), "geometry")
  expect_s3_class(ms_union(ce_poly_sfc, ce_inner_poly_sf), "sfc")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_union(ce_poly_sf, ce_inner_poly_sf, sys = TRUE), "sf")
})

## ERRORS

test_that("union fails properly", {
  skip_on_old_v8()
  err_msg <- "Target and Union must be an sf or sfc object with POLYGON or MULTIPLOYGON geometry"
  expect_error(ms_union(ce_points_sf, ce_inner_poly_spdf), err_msg)
  expect_error(ms_union(ce_poly_sf, ce_points_sf), err_msg)
})

test_that("ms_union fails with old v8", {
  skip_if_not(v8_version() < 6, "Not old v8")
  expect_error(ms_union(ce_poly, ce_inner_poly))
})

test_that("error occurs when non-identical crs in sf", {
  skip_on_old_v8()
  diff_crs <- sf::st_transform(ce_inner_poly_sf, 3005)
  expect_error(ms_union(ce_poly_sf, diff_crs), "target and union do not have identical CRS.")
})