context("ms_dissolve")
suppressPackageStartupMessages({
  library("geojsonio")
  library("sp")
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

poly_list <- geojson_list(poly)
poly_spdf <- geojson_sp(poly)
poly_sp <- as(poly_spdf, "SpatialPolygons")

points_list <- geojson_list(points)
points_spdf <- geojson_sp(points)
points_sp <- as(points_spdf, "SpatialPoints")

test_that("ms_dissolve.geo_json works", {
  out_poly <- ms_dissolve(poly)
  expect_is(out_poly, "geo_json")
  expect_equal(length(geojson_list(out_poly)$features), 1)
  expect_equal(out_poly, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],[103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],[101,0],[100,0]]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                             "geo_json")))

  out_points <- ms_dissolve(points)
  expect_equal(out_points, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-95.89715805641582,56.33174194239571]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json",
"geo_json")))

})

test_that("ms_dissolve.geo_json errors correctly", {
  expect_error(ms_dissolve('{foo: "bar"}'), "Input is not valid geojson")
})

test_that("ms_dissolve.character works", {
  out_poly <- ms_dissolve(unclass(poly))
  expect_is(out_poly, "geo_json")
  expect_equal(length(geojson_list(out_poly)$features), 1)
  expect_equal(out_poly, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],[103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],[101,0],[100,0]]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                             "geo_json")))

  out_points <- ms_dissolve(unclass(points))
  expect_equal(out_points, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-95.89715805641582,56.33174194239571]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json",
"geo_json")))

})

test_that("ms_dissolve.geo_list works", {
  out_poly <- ms_dissolve(poly_list)
  expect_is(out_poly, "geo_list")
  expect_equal(length(out_poly$features), 1)
  expect_equal(out_poly, structure(list(type = "FeatureCollection", features = list(structure(list(
    type = "Feature", geometry = structure(list(type = "MultiPolygon",
                                                coordinates = list(list(list(list(102L, 2L), list(102L,
                                                                                                  3L), list(103L, 3L), list(103L, 2L), list(102L, 2L))),
                                                                   list(list(list(100L, 0L), list(100L, 1L), list(101L,
                                                                                                                  1L), list(101L, 0L), list(100L, 0L))))), .Names = c("type",
                                                                                                                                                                      "coordinates")), properties = structure(list(rmapshaperid = 0L), .Names = "rmapshaperid")), .Names = c("type",
                                                                                                                                                                                                                                                                             "geometry", "properties")))), .Names = c("type", "features"), class = "geo_list", from = "json"))

  out_points <- ms_dissolve(points_list)
  expect_equal(out_points, structure(list(type = "FeatureCollection", features = list(structure(list(
    type = "Feature", geometry = structure(list(type = "Point",
        coordinates = list(-95.8971580564158, 56.3317419423957)), .Names = c("type",
    "coordinates")), properties = structure(list(rmapshaperid = 0L), .Names = "rmapshaperid")), .Names = c("type",
"geometry", "properties")))), .Names = c("type", "features"), class = "geo_list", from = "json"))

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

})

test_that("copy_fields and sum_fields works", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],[103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],[101,0],[100,0]]]]},\"properties\":{\"a\":1,\"b\":2,\"rmapshaperid\":0}}\n]}", class = c("json",
"geo_json"))
  expect_equal(ms_dissolve(poly_attr, copy_fields = c("a", "b")), expected_out)

  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],[103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],[101,0],[100,0]]]]},\"properties\":{\"a\":6,\"b\":5,\"rmapshaperid\":0}}\n]}", class = c("json",
"geo_json"))
  expect_equal(ms_dissolve(poly_attr, sum_fields = c("a", "b")), expected_out)
})

## sf classes
if (suppressPackageStartupMessages(require("sf", quietly = TRUE))) {
  points_sf <- st_as_sf(points_spdf)
  poly_sf <- st_as_sf(poly_spdf)

  test_that("ms_dissolve.sf works with points", {
    expect_is(ms_dissolve(points_sf), "sf")
    expect_is(ms_dissolve(st_geometry(points_sf)), "sfc")
  })

  test_that("ms_dissolve.sf works with polygons", {
    expect_is(ms_dissolve(poly_sf), "sf")
    expect_is(ms_dissolve(st_geometry(poly_sf)), "sfc")
  })

  test_that("weight argument works", {
    expect_error(ms_dissolve(points, weight = "w"), "APIError")
    expect_error(ms_dissolve(points_sf, weight = "w"), "specified 'weight' column not present in input data")
    expect_gt(sum(sf::st_coordinates(ms_dissolve(points_sf, weight = "foo"))),
              sum(sf::st_coordinates(ms_dissolve(points_sf))))
    expect_gt(sum(sp::coordinates(ms_dissolve(points_spdf, weight = "foo"))),
              sum(sp::coordinates(ms_dissolve(points_spdf))))
  })
}
