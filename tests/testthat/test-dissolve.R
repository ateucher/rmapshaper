context("ms_dissolve")
suppressPackageStartupMessages({
  library("geojsonio")
  library("sp")
  library("sf", quietly = TRUE)
})

poly <- structure('{"type":"FeatureCollection",
  "features":[
  {"type":"Feature",
  "properties":{},
  "geometry":{"type":"Polygon","coordinates":[[
  [102,2],[102,3],[103,3],[103,2],[102,2]
  ]]}}
  ,{"type":"Feature",
  "properties":{},
  "geometry":{"type":"Polygon","coordinates":[[
  [100,0],[100,1],[101,1],[101,0],[100,0]
  ]]}}]}', class = c("json", "geo_json"))

poly_attr <- structure('{"type":"FeatureCollection",
  "features":[
  {"type":"Feature",
  "properties":{"a": 1, "b": 2},
  "geometry":{"type":"Polygon","coordinates":[[
  [102,2],[102,3],[103,3],[103,2],[102,2]
  ]]}}
  ,{"type":"Feature",
  "properties":{"a": 5, "b": 3},
  "geometry":{"type":"Polygon","coordinates":[[
  [100,0],[100,1],[101,1],[101,0],[100,0]
  ]]}}]}', class = c("json", "geo_json"))

points <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-78.4154562738861,-53.95000746272258]},\"properties\":{\"x\":-78,\"y\":-53,\"foo\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-70.8687480648099,65.19505422895163]},\"properties\":{\"x\":-71,\"y\":65,\"foo\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[135.65518268439885,63.10517782011297]},\"properties\":{\"x\":135,\"y\":65,\"foo\":2}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   "geo_json"))
poly_spdf <- geojson_sp(poly)
poly_sp <- as(poly_spdf, "SpatialPolygons")

points_spdf <- geojson_sp(points)
points_sp <- as(points_spdf, "SpatialPoints")

test_that("ms_dissolve.geo_json works", {
  out_poly <- ms_dissolve(poly)
  expect_is(out_poly, "geo_json")
  expect_equal(nrow(geojson_sf(out_poly)), 1)
  expect_equivalent(out_poly, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],[103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],[101,0],[100,0]]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json","geo_json")))

  out_points <- ms_dissolve(points)
  expect_is(out_points, "geo_json")
  expect_equivalent(out_points, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-95.89715805641582,56.33174194239571]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json","geo_json")))

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_dissolve(points, sys = TRUE), "geo_json")
})

test_that("ms_dissolve.geo_json errors correctly", {
  expect_error(ms_dissolve('{foo: "bar"}'), "Input is not valid geojson")
})

test_that("ms_dissolve.character works", {
  out_poly <- ms_dissolve(unclass(poly))
  expect_is(out_poly, "geo_json")
  expect_equal(nrow(geojson_sf(out_poly)), 1)
  # expect_equal(out_poly, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],[103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],[101,0],[100,0]]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json")))
  out_points <- ms_dissolve(unclass(points))
  expect_is(out_points, "geo_json")
  # expect_equal(out_points, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-95.89715805641582,56.33174194239571]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json","geo_json")))

})

test_that("ms_dissolve.SpatialPolygons works", {
  out_poly <- ms_dissolve(poly_spdf)
  expect_is(out_poly, "SpatialPolygonsDataFrame")
  expect_equal(length(out_poly@polygons), 1)

  out_points <- ms_dissolve(points_spdf)
  expect_is(out_points, "SpatialPointsDataFrame")
  expect_equal(nrow(out_points@coords), 1)

  out_poly <- ms_dissolve(poly_sp)
  expect_is(out_poly, "SpatialPolygons")
  expect_equal(length(out_poly@polygons), 1)

  out_points <- ms_dissolve(points_sp)
  expect_is(out_points, "SpatialPoints")
  expect_equal(nrow(out_points@coords), 1)

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_dissolve(poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
})

test_that("copy_fields and sum_fields works", {
  expect_equal(as.list(geojson_sf(ms_dissolve(poly_attr, copy_fields = c("a", "b"))))[1:3],
               list(a = 1L, b = 2L, rmapshaperid = 0L))

  expect_equal(as.list(geojson_sf(ms_dissolve(poly_attr, sum_fields = c("a", "b"))))[1:3],
               list(a = 6L, b = 5L, rmapshaperid = 0L))
})

## sf classes
points_sf <- st_as_sf(points_spdf)
poly_sf <- st_as_sf(poly_spdf)

test_that("ms_dissolve.sf works with points", {
  expect_is(ms_dissolve(points_sf), "sf")
  expect_is(ms_dissolve(st_geometry(points_sf)), "sfc")
})

test_that("ms_dissolve.sf works with polygons", {
  expect_is(ms_dissolve(poly_sf), "sf")
  expect_is(ms_dissolve(st_geometry(poly_sf)), "sfc")
  skip_if_not(has_sys_mapshaper())
  expect_is(ms_dissolve(poly_sf, sys = TRUE), "sf")
})

test_that("weight argument works", {
  # Don't test this as the V8 error throws a warning
  expect_error(ms_dissolve(points, weight = "w"), class = "std::runtime_error")
  expect_error(ms_dissolve(points_sf, weight = "w"), "specified 'weight' column not present in input data")
  expect_gt(sum(sf::st_coordinates(ms_dissolve(points_sf, weight = "foo"))),
            sum(sf::st_coordinates(ms_dissolve(points_sf))))
  expect_gt(sum(sp::coordinates(ms_dissolve(points_spdf, weight = "foo"))),
            sum(sp::coordinates(ms_dissolve(points_spdf))))
})
