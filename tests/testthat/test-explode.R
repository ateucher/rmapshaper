context("ms_explode")
library(geojsonio)

js <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{
"type": "MultiPolygon",
"coordinates": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0],
[102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0],
[100.0, 0.0]]]]
}}]}', class = c("json", "geo_json"))

multi_line <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"MultiLineString","coordinates":[[[-49.21875,47.517200697839414],[-27.773437499999996,52.696361078274485],[-29.179687499999996,41.77131167976407],[-39.7265625,43.58039085560784]],[[-39.0234375,26.43122806450644],[-17.9296875,38.8225909761771],[-22.5,31.353636941500987],[-30.585937499999996,24.206889622398023],[-24.960937499999996,20.632784250388028]]]}}]} ', class = c("json", "geo_json"))

multi_point <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type": "MultiPoint","coordinates": [ [100.0, 0.0], [101.0, 1.0] ]}}]}', class = c("json", "geo_json"))

test_that("ms_explode.geo_json works", {
  out <- ms_explode(js)
  expect_is(out, "geo_json")
  expect_equal(length(geojson_list(out)$features), 2)
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                       "geo_json")))
})

test_that("ms_explode.geo_json errors correctly", {
  expect_error(ms_explode("foo"), "Input is not valid geojson")
})

test_that("ms_explode.character works", {
  out <- ms_explode(unclass(js))
  expect_is(out, "geo_json")
  expect_equal(length(geojson_list(out)$features), 2)
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                       "geo_json")))
})

test_that("ms_explode.geo_list works", {
  out <- ms_explode(geojson_list(js))
  expect_is(out, "geo_list")
  expect_equal(length(out$features), 2)
  expect_equal(out, structure(list(type = "FeatureCollection", features = list(structure(list(
    type = "Feature", geometry = structure(list(type = "Polygon",
                                                coordinates = list(list(list(102L, 2L), list(102L, 3L),
                                                                        list(103L, 3L), list(103L, 2L), list(102L, 2L)))), .Names = c("type",
                                                                                                                                      "coordinates")), properties = structure(list(rmapshaperid = 0L), .Names = "rmapshaperid")), .Names = c("type",
                                                                                                                                                                                                                                             "geometry", "properties")), structure(list(type = "Feature",
                                                                                                                                                                                                                                                                                        geometry = structure(list(type = "Polygon", coordinates = list(
                                                                                                                                                                                                                                                                                          list(list(100L, 0L), list(100L, 1L), list(101L, 1L),
                                                                                                                                                                                                                                                                                               list(101L, 0L), list(100L, 0L)))), .Names = c("type",
                                                                                                                                                                                                                                                                                                                                             "coordinates")), properties = structure(list(rmapshaperid = 1L), .Names = "rmapshaperid")), .Names = c("type",
                                                                                                                                                                                                                                                                                                                                                                                                                                                    "geometry", "properties")))), .Names = c("type", "features"), class = "geo_list", from = "json"))
})

test_that("ms_explode.SpatialPolygonsDataFrame works", {
  spdf <- rgdal::readOGR(js, layer='OGRGeoJSON', verbose=FALSE)
  out <- ms_explode(spdf, force_FC = TRUE)
  expect_is(out, "SpatialPolygonsDataFrame")
  # Temporarily remove due to bug in GDAL 2.1.0
  #expect_equal(length(out@polygons), 2)
  sp_dis <- sp::disaggregate(spdf)
  # Temporarily remove due to bug in GDAL 2.1.0
  # expect_equal(lapply(out@polygons, function(x) x@Polygons[[1]]@coords),
  #             lapply(sp_dis@polygons, function(x) x@Polygons[[1]]@coords))
})

test_that("ms_explode works with lines", {
  multi_line_exploded <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[-49.21875,47.517200697839414],[-27.773437499999996,52.696361078274485],[-29.179687499999996,41.77131167976407],[-39.7265625,43.58039085560784]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[-39.0234375,26.43122806450644],[-17.9296875,38.8225909761771],[-22.5,31.353636941500987],[-30.585937499999996,24.206889622398023],[-24.960937499999996,20.632784250388028]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          "geo_json"))

  expect_equal(ms_explode(multi_line), multi_line_exploded)
  expect_equal(ms_explode(geojson_list(multi_line)), geojson_list(multi_line_exploded))

  sp_lines <- geojsonio::geojson_sp(multi_line_exploded)
  out <- ms_explode(sp_lines)
  out_disagg <- sp::disaggregate(sp_lines)
  expect_equal(lapply(out@lines, function(x) x@Lines[[1]]@coords),
               lapply(out_disagg@lines, function(x) x@Lines[[1]]@coords))
})

test_that("ms_explode works with points", {
  multi_point_exploded <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[100,0]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[101,1]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                 "geo_json"))
  expect_equal(ms_explode(multi_point), multi_point_exploded)
  expect_equal(ms_explode(geojson_list(multi_point)), geojson_list(multi_point_exploded))
  # expect_is(ms_explode(geojsonio::geojson_sp(multi_point)), spatialPointsDataFrame)
})