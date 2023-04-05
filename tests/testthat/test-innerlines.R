innerlines_poly <- structure('{"type":"FeatureCollection",
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
[102,1],[102,2],[103,2],[103,1],[102,1]
]]}},
{"type":"Feature",
"properties":{"foo": "b"},
"geometry":{"type":"Polygon","coordinates":[[
[103,1],[103,2],[104,2],[104,1],[103,1]
]]}}]}', class = c("geojson", "json"))

innerlines_poly_spdf <- GeoJSON_to_sp(innerlines_poly)
innerlines_poly_sp <- as(innerlines_poly_spdf, "SpatialPolygons")

innerlines_poly_sf <- read_sf(unclass(innerlines_poly))
innerlines_poly_sfc <- st_geometry(innerlines_poly_sf)


test_that("ms_innerlines works with all classes", {
  out_json <- ms_innerlines(innerlines_poly)
  expect_s3_class(out_json, "geojson")
  expect_snapshot_value(out_json, style = "json2")
  expect_s3_class(ms_innerlines(unclass(innerlines_poly)), "geojson")

  expected_sp <- as(GeoJSON_to_sp(out_json), "SpatialLines")

  expect_equivalent(ms_innerlines(innerlines_poly_spdf), expected_sp)
  expect_equivalent(ms_innerlines(innerlines_poly_sp), expected_sp)

  expected_sf <- st_geometry(read_sf(unclass(out_json)))
  expect_equivalent(ms_innerlines(innerlines_poly_sf), expected_sf)
  expect_equivalent(ms_innerlines(innerlines_poly_sfc), expected_sf)
})

test_that("ms_innerlines errors correctly", {
  expect_error(ms_innerlines('{foo: "bar"}'), "Input is not valid geojson")
  expect_error(ms_innerlines(innerlines_poly, force_FC = "true"), "force_FC must be TRUE or FALSE")
  # Don't test this as the V8 error throws a warning
  expect_warning(ms_innerlines(ms_lines(innerlines_poly)), "The command returned an empty response")
})

test_that("ms_innerlines works with sys = TRUE", {
  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_innerlines(innerlines_poly, sys = TRUE), "geojson")
  expect_snapshot_value(ms_innerlines(innerlines_poly, sys = TRUE), style = "json2")

  expect_s4_class(ms_innerlines(innerlines_poly_spdf, sys = TRUE), "SpatialLines")
  expect_s3_class(ms_innerlines(innerlines_poly_sf, sys = TRUE), "sfc")
})
