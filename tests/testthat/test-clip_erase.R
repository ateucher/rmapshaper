test_that("ms_clip.geojson works", {
  skip_on_old_v8()
  default_clip_json <- ms_clip(ce_poly, ce_inner_poly)

  expect_s3_class(default_clip_json, "geojson")
  expect_snapshot_value(default_clip_json, style = "json2")
  expect_true(jsonify::validate_json(default_clip_json))

  skip_if_not(has_sys_mapshaper())
  out_sys <- ms_clip(ce_poly, ce_inner_poly, sys = TRUE)
  expect_s3_class(out_sys, "geojson")
  expect_snapshot_value(out_sys, style = "json2")

  out_sys_nofc <- ms_clip(ce_poly, ce_inner_poly, sys = TRUE, force_FC = FALSE)
  expect_s3_class(out_sys_nofc, "geojson")
  expect_snapshot_value(out_sys_nofc, style = "json2")
})

test_that("ms_clip.character works", {
  skip_on_old_v8()
  default_clip_json <- ms_clip(unclass(ce_poly), unclass(ce_inner_poly))

  expect_s3_class(default_clip_json, "geojson")
  expect_snapshot_value(default_clip_json, style = "json2")
  expect_true(jsonify::validate_json(default_clip_json))
})

test_that("ms_erase.geojson works", {
  skip_on_old_v8()
  default_erase_json <- ms_erase(ce_poly, ce_inner_poly)

  expect_s3_class(default_erase_json, "geojson")
  expect_snapshot_value(default_erase_json, style = "json2")
  expect_true(jsonify::validate_json(default_erase_json))

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_erase(ce_poly, ce_inner_poly, sys = TRUE), "geojson")
})

test_that("ms_erase.character works", {
  skip_on_old_v8()
  default_erase_json <- ms_erase(unclass(ce_poly), unclass(ce_inner_poly))

  expect_s3_class(default_erase_json, "geojson")
  expect_snapshot_value(default_erase_json, style = "json2")
  expect_true(jsonify::validate_json(default_erase_json))
})

## Spatial Classes
test_that("ms_clip.SpatialPolygons works", {
  skip_on_old_v8()
  default_clip_spdf <- ms_clip(ce_poly_spdf, ce_inner_poly_spdf)

  expect_s4_class(default_clip_spdf, "SpatialPolygonsDataFrame")
  expect_equivalent(sapply(default_clip_spdf@polygons[[1]]@Polygons, function(x) length(x@coords)), 10)
  expect_true(sf::st_is_valid(sf::st_as_sf(default_clip_spdf)))

  default_clip_sp <- ms_clip(ce_poly_sp, ce_inner_poly_spdf)
  expect_equivalent(as(default_clip_spdf, "SpatialPolygons"), default_clip_sp)

  skip_if_not(has_sys_mapshaper())
  expect_s4_class(ms_clip(ce_poly_spdf, ce_inner_poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("ms_erase.SpatialPolygons works", {
  skip_on_old_v8()
  default_erase_spdf <- ms_erase(ce_poly_spdf, ce_inner_poly_spdf)

  expect_s4_class(default_erase_spdf, "SpatialPolygonsDataFrame")
  expect_equivalent(sapply(default_erase_spdf@polygons[[1]]@Polygons, function(x) length(x@coords)), 14)
  expect_true(sf::st_is_valid(sf::st_as_sf(default_erase_spdf)))

  default_erase_sp <- ms_erase(ce_poly_sp, ce_inner_poly_spdf)
  expect_equivalent(as(default_erase_spdf, "SpatialPolygons"), default_erase_sp)

  skip_if_not(has_sys_mapshaper())
  expect_s4_class(ms_erase(ce_poly_spdf, ce_inner_poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("ms_clip works with lines", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"LineString","coordinates":[[55,-40.125],[52,-42]]},"properties":{"rmapshaperid":0}}
]}', class = c("json","geojson"))

  expect_snapshot_value(ms_clip(ce_line, ce_inner_poly), style = "json2")
  expect_equivalent(ms_clip(ce_line_spdf, GeoJSON_to_sp(ce_inner_poly)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_clip(ce_line_sp, GeoJSON_to_sp(ce_inner_poly)), as(GeoJSON_to_sp(expected_out), "SpatialLines"))
  expect_snapshot_value(ms_clip(ce_line, bbox = c(51, -45, 55, -40)), style = "json2")
  expect_equivalent(ms_clip(ce_line_spdf, bbox = c(51, -45, 55, -40)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_clip(ce_line_sp, bbox = c(51, -45, 55, -40)), as(GeoJSON_to_sp(expected_out), "SpatialLines"))
})

test_that("ms_erase works with lines", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"LineString","coordinates":[[60,-37],[55,-40.125]]},"properties":{"rmapshaperid":0}}
]} ', class = c("geojson", "json"))

  expect_snapshot_value(ms_erase(ce_line, ce_inner_poly), style = "json2")
  expect_equivalent(ms_erase(ce_line_spdf, GeoJSON_to_sp(ce_inner_poly)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_erase(ce_line_sp, GeoJSON_to_sp(ce_inner_poly)), as(GeoJSON_to_sp(expected_out), "SpatialLines"))
  expect_snapshot_value(ms_erase(ce_line, bbox = c(51, -45, 55, -40)), style = "json2")
  expect_equivalent(ms_erase(ce_line_spdf, bbox = c(51, -45, 55, -40)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_erase(ce_line_sp, bbox = c(51, -45, 55, -40)), as(GeoJSON_to_sp(expected_out), "SpatialLines"))
})

test_that("ms_clip works with points", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Point","coordinates":[53,-42]},"properties":{"rmapshaperid":0}}
]}', class = c("geojson", "json"))

  expect_snapshot_value(ms_clip(ce_points, ce_inner_poly), style = "json2")
  expect_equivalent(ms_clip(ce_points_spdf, GeoJSON_to_sp(ce_inner_poly)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_clip(ce_points_sp, GeoJSON_to_sp(ce_inner_poly)), as(GeoJSON_to_sp(expected_out), "SpatialPoints"))
  expect_snapshot_value(ms_clip(ce_points, bbox = c(51, -45, 55, -40)), style = "json2")
  expect_equivalent(ms_clip(ce_points_spdf, bbox = c(51, -45, 55, -40)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_clip(ce_points_sp, bbox = c(51, -45, 55, -40)), as(GeoJSON_to_sp(expected_out), "SpatialPoints"))
})

test_that("ms_erase works with points", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Point","coordinates":[57,-42]},"properties":{"rmapshaperid":0}}
]}', class = c("geojson", "json"))

  expect_snapshot_value(ms_erase(ce_points, ce_inner_poly), style = "json2")
  expect_equivalent(ms_erase(ce_points_spdf, GeoJSON_to_sp(ce_inner_poly)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_erase(ce_points_sp, GeoJSON_to_sp(ce_inner_poly)), as(GeoJSON_to_sp(expected_out), "SpatialPoints"))
  expect_snapshot_value(ms_erase(ce_points, bbox = c(51, -45, 55, -40)), style = "json2")
  expect_equivalent(ms_erase(ce_points_spdf, bbox = c(51, -45, 55, -40)), GeoJSON_to_sp(expected_out))
  expect_equivalent(ms_erase(ce_points_sp, bbox = c(51, -45, 55, -40)), as(GeoJSON_to_sp(expected_out), "SpatialPoints"))
})

test_that("bbox works", {
  skip_on_old_v8()
  out <- ms_erase(ce_poly, bbox = c(51, -45, 55, -40))
  expect_s3_class(out, "geojson")
  expect_snapshot_value(out, style = "json2")
  out <- ms_clip(ce_poly, bbox = c(51, -45, 55, -40))
  expect_s3_class(out, "geojson")
  expect_snapshot_value(out, style = "json2")

  expect_error(ms_erase(ce_poly), "You must specificy either a bounding box")
  expect_error(ms_erase(ce_poly, "foo", c(1,2,3,4)), "Please only specify either a bounding box")
  expect_error(ms_clip(ce_poly, bbox = c(1,2,3)), "bbox must be a numeric vector of length 4")
  expect_error(ms_clip(ce_poly, bbox = c("a","b","c", "d")), "bbox must be a numeric vector of length 4")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_clip(ce_poly, bbox = c(51, -45, 55, -40), sys = TRUE), "geojson")
  expect_s3_class(ms_erase(ce_poly, bbox = c(51, -45, 55, -40), sys = TRUE), "geojson")
})

## test sf classes

test_that("clip works with sf objects", {
  skip_on_old_v8()
  expect_s3_class(ms_clip(ce_poly_sf, ce_inner_poly_sf), "sf")
  expect_equivalent(names(ms_clip(ce_poly_sf, ce_inner_poly_sf)), c("rmapshaperid", "geometry"))
  expect_s3_class(ms_clip(ce_poly_sfc, ce_inner_poly_sf), "sfc")
  expect_s3_class(ms_clip(ce_lines_sf, ce_inner_poly_sf), "sf")
  expect_s3_class(ms_clip(ce_points_sf, ce_inner_poly_sf), "sf")
  expect_s3_class(ms_clip(ce_poly_sf, bbox = c(51, -45, 55, -40)), "sf")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_clip(ce_poly_sf, ce_inner_poly_sf, sys = TRUE), "sf")
})

test_that("erase works with sf objects", {
  skip_on_old_v8()
  expect_s3_class(ms_erase(ce_poly_sf, ce_inner_poly_sf), "sf")
  expect_equivalent(names(ms_erase(ce_poly_sf, ce_inner_poly_sf)), c("rmapshaperid", "geometry"))
  expect_s3_class(ms_erase(ce_poly_sfc, ce_inner_poly_sf), "sfc")
  expect_s3_class(ms_erase(ce_lines_sf, ce_inner_poly_sf), "sf")
  expect_s3_class(ms_erase(ce_points_sf, ce_inner_poly_sf), "sf")
  expect_s3_class(ms_erase(ce_poly_sf, bbox = c(51, -45, 55, -40)), "sf")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_erase(ce_poly_sf, ce_inner_poly_sf, sys = TRUE), "sf")
})

test_that("clip and erase fail properly", {
  skip_on_old_v8()
  err_msg <- "must be an sf or sfc object with POLYGON or MULTIPLOYGON geometry"
  expect_error(ms_clip(ce_points_sf, ce_inner_poly_spdf), err_msg)
  expect_error(ms_erase(ce_points_sf, ce_inner_poly_spdf), err_msg)
  expect_error(ms_clip(ce_poly_sf, ce_points_sf), err_msg)
  expect_error(ms_erase(ce_poly_sf, ce_points_sf), err_msg)
})

test_that("ms_clip and ms_erase fail with old v8", {
  skip_if_not(check_v8_major_version() < 6, "Not old v8")
  expect_error(ms_clip(ce_poly, ce_inner_poly))
  expect_error(ms_erase(ce_poly, ce_inner_poly))
})

test_that("error occurs when non-identical crs in sf", {
  skip_on_old_v8()
  diff_crs <- sf::st_transform(ce_inner_poly_sf, 3005)
  expect_error(ms_clip(ce_poly_sf, diff_crs), "target and clip do not have identical CRS")
  expect_error(ms_erase(ce_poly_sf, diff_crs), "target and erase do not have identical CRS")
})
