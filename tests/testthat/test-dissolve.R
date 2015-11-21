context("ms_dissolve")
library(geojsonio)
# library(sp)

js <- structure('{"type":"FeatureCollection",
  "features":[
  {"type":"Feature",
  "properties":{"rmapshaperid":0},
  "geometry":{"type":"Polygon","coordinates":[[
  [102,2],[102,3],[103,3],[103,2],[102,2]
  ]]}}
  ,{"type":"Feature",
  "properties":{"rmapshaperid":1},
  "geometry":{"type":"Polygon","coordinates":[[
  [100,0],[100,1],[101,1],[101,0],[100,0]
  ]]}}]}', class = c("json", "geo_json"))

js_list <- geojson_list(js)

test_that("ms_dissolve.geo_json works", {
  out <- ms_dissolve(js)
  expect_is(out, "geo_json")
  expect_equal(length(geojson_list(out)$features), 1)
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"rmapshaperid\":0},\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],[103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],[101,0],[100,0]]]]}}]}", class = c("json", "geo_json")))
})

test_that("ms_dissolve.geo_json errors correctly", {
  expect_error(ms_dissolve(structure("foo", class = "geo_json")),
               "Not a valid geo_json object")
})

test_that("ms_dissolve.geo_list works", {
  out <- ms_dissolve(js_list)
  expect_is(out, "geo_list")
  expect_equal(length(out$features), 1)
  expect_equal(out, structure(list(type = "FeatureCollection", features = list(structure(list(
    type = "Feature", properties = structure(list(rmapshaperid = 0L), .Names = "rmapshaperid"),
    geometry = structure(list(type = "MultiPolygon", coordinates = list(
      list(list(list(102L, 2L), list(102L, 3L), list(103L,
                                                     3L), list(103L, 2L), list(102L, 2L))), list(list(
                                                       list(100L, 0L), list(100L, 1L), list(101L, 1L), list(
                                                         101L, 0L), list(100L, 0L))))), .Names = c("type",
                                                                                                   "coordinates"))), .Names = c("type", "properties", "geometry"
                                                                                                   )))), .Names = c("type", "features"), class = "geo_list", from = "json"))
})

test_that("ms_dissolve.SpatialPolygonsDataFrame works", {
  spdf <- rgdal::readOGR(js, layer='OGRGeoJSON', verbose=FALSE)
  out <- ms_dissolve(spdf)
  expect_is(out, "SpatialPolygonsDataFrame")
  expect_equal(length(out@polygons), 1)
  # sp_agg <- aggregate(spdf)
  # expect_equal(lapply(out@polygons, function(x) x@Polygons[[1]]@coords),
  #              lapply(sp_agg@polygons, function(x) x@Polygons[[1]]@coords))
})