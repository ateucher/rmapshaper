context("ms_clip_erase")
suppressPackageStartupMessages({
  library("geojsonlint", quietly = TRUE)
  library("geojsonio", quietly = TRUE)
  library("sf", quietly = TRUE)
})

poly <- structure('{"type":"FeatureCollection","features":[{
"type": "Feature",
"properties": {},
"geometry": {
"type": "Polygon",
"coordinates": [
[
[53, -42],
[57, -42],
[57, -47],
[53, -47],
[53, -42]
]
]
}}]
}', class = c("json", "geo_json"))

line <- structure('{"type":"FeatureCollection","features":[
{ "type": "Feature",
"geometry": {
"type": "LineString",
"coordinates": [
[60, -37], [52, -42]
]
},
"properties": {}
}]
}', class = c("json", "geo_json"))

points <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[53,-42]},"properties":{}},{"type":"Feature","geometry":{"type":"Point","coordinates":[57,-42]},"properties":{}}]}', class = c("json", "geo_json"))

clip_poly <- structure('{
"type": "Feature",
"properties": {},
"geometry": {
"type": "Polygon",
"coordinates": [
[
[51, -40],
[55, -40],
[55, -45],
[51, -45],
[51, -40]
]
]
}
}', class = c("json", "geo_json"))

poly_spdf <- geojsonio::geojson_sp(poly)
poly_sp <- as(poly_spdf, "SpatialPolygons")

line_list <- geojson_list(line)
line_spdf <- geojson_sp(line)
line_sp <- as(line_spdf, "SpatialLines")

points_list <- geojson_list(points)
points_spdf <- geojson_sp(points)
points_sp <- as(points_spdf, "SpatialPoints")

clip_poly_spdf <- geojsonio::geojson_sp(clip_poly)

test_that("ms_clip.geo_json works", {
  skip_on_old_v8()
  default_clip_json <- ms_clip(poly, clip_poly)

  expect_is(default_clip_json, "geo_json")
  # expect_equivalent(default_clip_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[54.02807275892674,-40],[55,-40],[55,-45],[51,-45],[51,-42.353820249760446],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_clip_json))

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_clip(poly, clip_poly, sys = TRUE), "geo_json")
})

test_that("ms_clip.character works", {
  skip_on_old_v8()
  default_clip_json <- ms_clip(unclass(poly), unclass(clip_poly))

  expect_is(default_clip_json, "geo_json")
  #expect_equivalent(default_clip_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[54.02807275892674,-40],[55,-40],[55,-45],[51,-45],[51,-42.353820249760446],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_clip_json))
})

test_that("ms_erase.geo_json works", {
  skip_on_old_v8()
  default_erase_json <- ms_erase(poly, clip_poly)

  expect_is(default_erase_json, "geo_json")
  #expect_equivalent(default_erase_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[54.02807275892674,-40],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[51,-42.353820249760446],[51,-45],[55,-45],[55,-40],[54.02807275892674,-40]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_erase_json))

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_erase(poly, clip_poly, sys = TRUE), "geo_json")
})

test_that("ms_erase.character works", {
  skip_on_old_v8()
  default_erase_json <- ms_erase(unclass(poly), unclass(clip_poly))

  expect_is(default_erase_json, "geo_json")
  #expect_equivalent(default_erase_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[54.02807275892674,-40],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[51,-42.353820249760446],[51,-45],[55,-45],[55,-40],[54.02807275892674,-40]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_erase_json))
})

## Spatial Classes
test_that("ms_clip.SpatialPolygons works", {
  skip_on_old_v8()
  default_clip_spdf <- ms_clip(poly_spdf, clip_poly_spdf)

  expect_is(default_clip_spdf, "SpatialPolygonsDataFrame")
  expect_equivalent(sapply(default_clip_spdf@polygons[[1]]@Polygons, function(x) length(x@coords)), 10)
  expect_true(rgeos::gIsValid(default_clip_spdf))

  default_clip_sp <- ms_clip(poly_sp, clip_poly_spdf)
  expect_equivalent(as(default_clip_spdf, "SpatialPolygons"), default_clip_sp)

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_clip(poly_spdf, clip_poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("ms_erase.SpatialPolygons works", {
  skip_on_old_v8()
  default_erase_spdf <- ms_erase(poly_spdf, clip_poly_spdf)

  expect_is(default_erase_spdf, "SpatialPolygonsDataFrame")
  expect_equivalent(sapply(default_erase_spdf@polygons[[1]]@Polygons, function(x) length(x@coords)), 14)
  expect_true(rgeos::gIsValid(default_erase_spdf))

  default_erase_sp <- ms_erase(poly_sp, clip_poly_spdf)
  expect_equivalent(as(default_erase_spdf, "SpatialPolygons"), default_erase_sp)

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_erase(poly_spdf, clip_poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("warning occurs when non-identical CRS", {
  skip_on_old_v8()
  diff_crs <- sp::spTransform(clip_poly_spdf, sp::CRS("+init=epsg:3005"))
  expect_warning(ms_clip(poly_spdf, diff_crs), "target and clip do not have identical CRS")
  expect_warning(ms_erase(poly_spdf, diff_crs), "target and erase do not have identical CRS")
})

test_that("ms_clip works with lines", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"LineString","coordinates":[[55,-40.125],[52,-42]]},"properties":{"rmapshaperid":0}}
]}', class = c("json","geo_json"))

  expect_equivalent(clean_ws(ms_clip(line, clip_poly)), clean_ws(expected_out))
  expect_equivalent(ms_clip(line_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equivalent(ms_clip(line_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equivalent(ms_clip(line_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialLines"))
  expect_equivalent(clean_ws(ms_clip(line, bbox = c(51, -45, 55, -40))), clean_ws(expected_out))
  expect_equivalent(ms_clip(line_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equivalent(ms_clip(line_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equivalent(ms_clip(line_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialLines"))
})

test_that("ms_erase works with lines", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"LineString","coordinates":[[60,-37],[55,-40.125]]},"properties":{"rmapshaperid":0}}
]} ', class = c("json", "geo_json"))

  expect_equivalent(clean_ws(ms_erase(line, clip_poly)), clean_ws(expected_out))
  expect_equivalent(ms_erase(line_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equivalent(ms_erase(line_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equivalent(ms_erase(line_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialLines"))
  expect_equivalent(clean_ws(ms_erase(line, bbox = c(51, -45, 55, -40))), clean_ws(expected_out))
  expect_equivalent(ms_erase(line_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equivalent(ms_erase(line_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equivalent(ms_erase(line_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialLines"))
})

test_that("ms_clip works with points", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Point","coordinates":[53,-42]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))
  expect_equivalent(clean_ws(ms_clip(points, clip_poly)), clean_ws(expected_out))
  expect_equivalent(ms_clip(points_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equivalent(ms_clip(points_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equivalent(ms_clip(points_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialPoints"))
  expect_equivalent(clean_ws(ms_clip(points, bbox = c(51, -45, 55, -40))), clean_ws(expected_out))
  expect_equivalent(ms_clip(points_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equivalent(ms_clip(points_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equivalent(ms_clip(points_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialPoints"))
})

test_that("ms_erase works with points", {
  skip_on_old_v8()
  expected_out <- structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Point","coordinates":[57,-42]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))
  expect_equivalent(clean_ws(ms_erase(points, clip_poly)), clean_ws(expected_out))
  expect_equivalent(ms_erase(points_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equivalent(ms_erase(points_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equivalent(ms_erase(points_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialPoints"))
  expect_equivalent(clean_ws(ms_erase(points, bbox = c(51, -45, 55, -40))), clean_ws(expected_out))
  expect_equivalent(ms_erase(points_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equivalent(ms_erase(points_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equivalent(ms_erase(points_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialPoints"))
})

test_that("bbox works", {
  skip_on_old_v8()
  out <- ms_erase(poly, bbox = c(51, -45, 55, -40))
  expect_is(out, "geo_json")
  expect_equivalent(clean_ws(out), clean_ws(structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[55,-42],[57,-42],[57,-47],[53,-47],[53,-45],[55,-45],[55,-42]]]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))))
  out <- ms_clip(poly, bbox = c(51, -45, 55, -40))
  expect_is(out, "geo_json")
  expect_equivalent(clean_ws(out), clean_ws(structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[53,-42],[55,-42],[55,-45],[53,-45],[53,-42]]]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))))

  expect_error(ms_erase(poly), "You must specificy either a bounding box")
  expect_error(ms_erase(poly, "foo", c(1,2,3,4)), "Please only specify either a bounding box")
  expect_error(ms_clip(poly, bbox = c(1,2,3)), "bbox must be a numeric vector of length 4")
  expect_error(ms_clip(poly, bbox = c("a","b","c", "d")), "bbox must be a numeric vector of length 4")

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_clip(poly, bbox = c(51, -45, 55, -40), sys = TRUE), "geo_json")
  expect_is(ms_erase(poly, bbox = c(51, -45, 55, -40), sys = TRUE), "geo_json")
})

## test sf classes

poly_sf <- st_as_sf(poly_spdf)
poly_sfc <- st_as_sfc(poly_sp)
lines_sf <- st_as_sf(line_spdf)
points_sf <- st_as_sf(points_spdf)

clip_sf <- read_sf(unclass(clip_poly))

test_that("clip works with sf objects", {
  skip_on_old_v8()
  expect_is(ms_clip(poly_sf, clip_sf), "sf")
  expect_equivalent(names(ms_clip(poly_sf, clip_sf)), c("rmapshaperid", "geometry"))
  expect_is(ms_clip(poly_sfc, clip_sf), "sfc")
  expect_is(ms_clip(lines_sf, clip_sf), "sf")
  expect_is(ms_clip(points_sf, clip_sf), "sf")
  expect_is(ms_clip(poly_sf, bbox = c(51, -45, 55, -40)), "sf")

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_clip(poly_sf, clip_sf, sys = TRUE), "sf")
})

test_that("erase works with sf objects", {
  skip_on_old_v8()
  expect_is(ms_erase(poly_sf, clip_sf), "sf")
  expect_equivalent(names(ms_erase(poly_sf, clip_sf)), c("rmapshaperid", "geometry"))
  expect_is(ms_erase(poly_sfc, clip_sf), "sfc")
  expect_is(ms_erase(lines_sf, clip_sf), "sf")
  expect_is(ms_erase(points_sf, clip_sf), "sf")
  expect_is(ms_erase(poly_sf, bbox = c(51, -45, 55, -40)), "sf")

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_erase(poly_sf, clip_sf, sys = TRUE), "sf")
})

test_that("clip and erase fail properly", {
  skip_on_old_v8()
  err_msg <- "must be an sf or sfc object with POLYGON or MULTIPLOYGON geometry"
  expect_error(ms_clip(points_sf, clip_poly_spdf), err_msg)
  expect_error(ms_erase(points_sf, clip_poly_spdf), err_msg)
  expect_error(ms_clip(poly_sf, points_sf), err_msg)
  expect_error(ms_erase(poly_sf, points_sf), err_msg)
})

test_that("ms_clip and ms_erase fail with old v8", {
  if (check_v8_major_version() < 6) {
    expect_error(ms_clip(poly, clip_poly))
    expect_error(ms_erase(poly, clip_poly))
  }
})
