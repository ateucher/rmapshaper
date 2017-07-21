context("ms_clip_erase")
suppressPackageStartupMessages({
  library("geojsonlint", quietly = TRUE)
  library("geojsonio", quietly = TRUE)
})

poly <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[52.8658,-44.7219]]]}}]}", class = c("json", "geo_json"))

line <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[52.8658,-44.7219],[53.7702,-40.4873],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[52.8658,-44.7219]]}}]}", class = c("json", "geo_json"))

points <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[52.8658,-44.7219]}},{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[53.7702,-40.4873]}},{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[55.3204,-37.5579]}},{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[56.2757,-37.917]}},{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[56.184,-40.6443]}},{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[61.0835,-40.7529]}},{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[58.0202,-43.634]}}]}", class = c("json", "geo_json"))

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

poly_spdf <- rgdal::readOGR(poly, "OGRGeoJSON", verbose = FALSE)
poly_sp <- as(poly_spdf, "SpatialPolygons")

line_list <- geojson_list(line)
line_spdf <- geojson_sp(line)
line_sp <- as(line_spdf, "SpatialLines")

points_list <- geojson_list(points)
points_spdf <- geojson_sp(points)
points_sp <- as(points_spdf, "SpatialPoints")

clip_poly_spdf <- rgdal::readOGR(clip_poly, "OGRGeoJSON", verbose = FALSE)

test_that("ms_clip.geo_json works", {
  default_clip_json <- ms_clip(poly, clip_poly)

  expect_is(default_clip_json, "geo_json")
  expect_equal(default_clip_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[54.02807275892674,-40],[55,-40],[55,-45],[51,-45],[51,-42.353820249760446],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_clip_json))
})

test_that("ms_clip.character works", {
  default_clip_json <- ms_clip(unclass(poly), unclass(clip_poly))

  expect_is(default_clip_json, "geo_json")
  expect_equal(default_clip_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[54.02807275892674,-40],[55,-40],[55,-45],[51,-45],[51,-42.353820249760446],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_clip_json))
})

test_that("ms_erase.geo_json works", {
  default_erase_json <- ms_erase(poly, clip_poly)

  expect_is(default_erase_json, "geo_json")
  expect_equal(default_erase_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[54.02807275892674,-40],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[51,-42.353820249760446],[51,-45],[55,-45],[55,-40],[54.02807275892674,-40]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_erase_json))
})

test_that("ms_erase.character works", {
  default_erase_json <- ms_erase(unclass(poly), unclass(clip_poly))

  expect_is(default_erase_json, "geo_json")
  expect_equal(default_erase_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[54.02807275892674,-40],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[51,-42.353820249760446],[51,-45],[55,-45],[55,-40],[54.02807275892674,-40]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  expect_true(geojsonlint::geojson_validate(default_erase_json))
})

## Spatial Classes
test_that("ms_clip.SpatialPolygons works", {
  default_clip_spdf <- ms_clip(poly_spdf, clip_poly_spdf)

  expect_is(default_clip_spdf, "SpatialPolygonsDataFrame")
  expect_equal(sapply(default_clip_spdf@polygons[[1]]@Polygons, function(x) length(x@coords)), 16)
  expect_true(rgeos::gIsValid(default_clip_spdf))

  default_clip_sp <- ms_clip(poly_sp, clip_poly_spdf)
  expect_equal(as(default_clip_spdf, "SpatialPolygons"), default_clip_sp)
})

test_that("ms_erase.SpatialPolygons works", {
  default_erase_spdf <- ms_erase(poly_spdf, clip_poly_spdf)

  expect_is(default_erase_spdf, "SpatialPolygonsDataFrame")
  expect_equal(sapply(default_erase_spdf@polygons[[1]]@Polygons, function(x) length(x@coords)), 50)
  expect_true(rgeos::gIsValid(default_erase_spdf))

  default_erase_sp <- ms_erase(poly_sp, clip_poly_spdf)
  expect_equal(as(default_erase_spdf, "SpatialPolygons"), default_erase_sp)
})

test_that("warning occurs when non-identical CRS", {
  diff_crs <- sp::spTransform(clip_poly_spdf, sp::CRS("+init=epsg:3005"))
  expect_warning(ms_clip(poly_spdf, diff_crs), "target and clip do not have identical CRS")
  expect_warning(ms_erase(poly_spdf, diff_crs), "target and erase do not have identical CRS")
})

test_that("ms_clip works with lines", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiLineString\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[54.02807275892674,-40]],[[51,-42.353820249760446],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json","geo_json"))

  expect_equal(ms_clip(line, clip_poly), expected_out)
  expect_equal(ms_clip(line_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equal(ms_clip(line_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equal(ms_clip(line_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialLines"))
  expect_equal(ms_clip(line, bbox = c(51, -45, 55, -40)), expected_out)
  expect_equal(ms_clip(line_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equal(ms_clip(line_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equal(ms_clip(line_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialLines"))
})

test_that("ms_erase works with lines", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[54.02807275892674,-40],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[51,-42.353820249760446]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))
  expect_equal(ms_erase(line, clip_poly), expected_out)
  expect_equal(ms_erase(line_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equal(ms_erase(line_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equal(ms_erase(line_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialLines"))
  expect_equal(ms_erase(line, bbox = c(51, -45, 55, -40)), expected_out)
  expect_equal(ms_erase(line_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equal(ms_erase(line_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equal(ms_erase(line_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialLines"))
})

test_that("ms_clip works with points", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[52.8658,-44.7219]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[53.7702,-40.4873]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))
  expect_equal(ms_clip(points, clip_poly), expected_out)
  expect_equal(ms_clip(points_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equal(ms_clip(points_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equal(ms_clip(points_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialPoints"))
  expect_equal(ms_clip(points, bbox = c(51, -45, 55, -40)), expected_out)
  expect_equal(ms_clip(points_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equal(ms_clip(points_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equal(ms_clip(points_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialPoints"))
})

test_that("ms_erase works with points", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[55.3204,-37.5579]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[56.2757,-37.917]},\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[56.184,-40.6443]},\"properties\":{\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[61.0835,-40.7529]},\"properties\":{\"rmapshaperid\":3}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[58.0202,-43.634]},\"properties\":{\"rmapshaperid\":4}}\n]}", class = c("json", "geo_json"))
  expect_equal(ms_erase(points, clip_poly), expected_out)
  expect_equal(ms_erase(points_list, geojson_list(clip_poly)), geojson_list(expected_out))
  expect_equal(ms_erase(points_spdf, geojson_sp(clip_poly)), geojson_sp(expected_out))
  expect_equal(ms_erase(points_sp, geojson_sp(clip_poly)), as(geojson_sp(expected_out), "SpatialPoints"))
  expect_equal(ms_erase(points, bbox = c(51, -45, 55, -40)), expected_out)
  expect_equal(ms_erase(points_list, bbox = c(51, -45, 55, -40)), geojson_list(expected_out))
  expect_equal(ms_erase(points_spdf, bbox = c(51, -45, 55, -40)), geojson_sp(expected_out))
  expect_equal(ms_erase(points_sp, bbox = c(51, -45, 55, -40)), as(geojson_sp(expected_out), "SpatialPoints"))
})

test_that("bbox works", {
  out <- ms_erase(poly, bbox = c(51, -45, 55, -40))
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[54.02807275892674,-40],[55.3204,-37.5579],[56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],[58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],[55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],[52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],[52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],[50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],[51,-42.353820249760446],[51,-45],[55,-45],[55,-40],[54.02807275892674,-40]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  out <- ms_clip(poly, bbox = c(51, -45, 55, -40))
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[54.02807275892674,-40],[55,-40],[55,-45],[51,-45],[51,-42.353820249760446],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))

  expect_error(ms_erase(poly), "You must specificy either a bounding box")
  expect_error(ms_erase(poly, "foo", c(1,2,3,4)), "Please only specify either a bounding box")
  expect_error(ms_clip(poly, bbox = c(1,2,3)), "bbox must be a numeric vector of length 4")
  expect_error(ms_clip(poly, bbox = c("a","b","c", "d")), "bbox must be a numeric vector of length 4")
})

## test sf classes
if (suppressPackageStartupMessages(require("sf", quietly = TRUE))) {

  poly_sf <- st_as_sf(poly_spdf)
  poly_sfc <- st_as_sfc(poly_sp)
  lines_sf <- st_as_sf(line_spdf)
  points_sf <- st_as_sf(points_spdf)

  clip_sf <- read_sf(clip_poly)

  test_that("clip works with sf objects", {
    expect_is(ms_clip(poly_sf, clip_sf), "sf")
    expect_equal(st_bbox(ms_clip(poly_sf, clip_sf)), st_bbox(clip_sf))
    expect_equal(names(ms_clip(poly_sf, clip_sf)), c("rmapshaperid", "geometry"))
    expect_is(ms_clip(poly_sfc, clip_sf), "sfc")
    expect_is(ms_clip(lines_sf, clip_sf), "sf")
    expect_is(ms_clip(points_sf, clip_sf), "sf")
    expect_is(ms_clip(poly_sf, bbox = c(51, -45, 55, -40)), "sf")
  })

  test_that("erase works with sf objects", {
    expect_is(ms_erase(poly_sf, clip_sf), "sf")
    expect_equal(st_bbox(ms_erase(poly_sf, clip_sf)), st_bbox(poly_sf))
    expect_equal(names(ms_erase(poly_sf, clip_sf)), c("rmapshaperid", "geometry"))
    expect_is(ms_erase(poly_sfc, clip_sf), "sfc")
    expect_is(ms_erase(lines_sf, clip_sf), "sf")
    expect_is(ms_erase(points_sf, clip_sf), "sf")
    expect_is(ms_erase(poly_sf, bbox = c(51, -45, 55, -40)), "sf")
  })

  test_that("clip and erase fail properly", {
    err_msg <- "must be an sf or sfc object with POLYGON or MULTIPLOYGON geometry"
    expect_error(ms_clip(points_sf, clip_poly_spdf), err_msg)
    expect_error(ms_erase(points_sf, clip_poly_spdf), err_msg)
    expect_error(ms_clip(poly_sf, points_sf), err_msg)
    expect_error(ms_erase(poly_sf, points_sf), err_msg)
  })
}

