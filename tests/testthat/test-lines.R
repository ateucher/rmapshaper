test_that("ms_lines works with all classes", {
  out_json <- ms_lines(innerlines_poly)
  expect_s3_class(out_json, "json")
  expect_snapshot_value(out_json, style = "json2")
  expect_s3_class(ms_lines(unclass(innerlines_poly)), "geojson")

  expected_sp <- GeoJSON_to_sp(out_json)
  expect_equivalent(ms_lines(innerlines_poly_spdf),
                    expected_sp[, setdiff(names(expected_sp), "rmapshaperid"), drop = FALSE])
  expect_equivalent(ms_lines(innerlines_poly_sp), as(expected_sp, "SpatialLines"))

  expected_sf <- read_sf(unclass(out_json))
  expected_sfc <- st_geometry(expected_sf)

  expect_equivalent(st_geometry(ms_lines(innerlines_poly_sf)), expected_sfc)
  expect_equivalent(ms_lines(innerlines_poly_sfc), expected_sfc)
})

test_that("ms_lines works with fields specified", {
  out_json <- ms_lines(innerlines_poly, "foo")
  expect_s3_class(out_json, "geojson")
  expect_snapshot_value(out_json, style = "json2")

  expected_sp <- GeoJSON_to_sp(out_json)


  expect_equivalent(ms_lines(innerlines_poly_spdf, "foo"),
                    expected_sp[, setdiff(names(expected_sp), "rmapshaperid"), drop = FALSE])

  expect_equivalent(ms_lines(innerlines_poly_sf, "foo")$RANK, c(2,2,1,1,0,0,0,0))
})

test_that("ms_lines errors correctly", {
  expect_error(ms_lines('{foo: "bar"}'), "Input is not valid geojson")
  # Don't test this as the V8 error throws a warning
  expect_warning(ms_lines(innerlines_poly, "bar"), "The command returned an empty response")
  expect_error(ms_lines(innerlines_poly_spdf, "bar"), "not all fields specified exist in input data")
  expect_error(ms_lines(innerlines_poly, 1), "fields must be a character vector")
  expect_error(ms_lines(innerlines_poly, force_FC = "true"), "force_FC must be TRUE or FALSE")

  expect_error(ms_lines(innerlines_poly_sfc, "foo"), "Do not specify fields for sfc classes")
})

test_that("ms_innerlines works with sys = TRUE", {
  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_lines(innerlines_poly, sys = TRUE), "geojson")
  expect_snapshot_value(ms_lines(innerlines_poly, sys = TRUE), style = "json2")
  expect_s4_class(ms_lines(innerlines_poly_spdf, sys = TRUE), "SpatialLinesDataFrame")
  expect_s3_class(ms_lines(innerlines_poly_sf, sys = TRUE), "sf")
})
