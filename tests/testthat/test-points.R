context("ms_points")
suppressPackageStartupMessages(library("geojsonio"))
has_sf <- suppressPackageStartupMessages(require("sf", quietly = TRUE))

poly_geo_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-76.3,-49.68],[-75.53,-51.13],[-74.71,-56.89],[-84.11,-57.09],[-77.9,-50.62],[-84.12,-49.59],[-76.3,-49.68]]]},\"properties\":{\"x\": -78, \"y\": -53}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-68.77,69.82],[-66.26,62.96],[-74.22,60.87],[-74.12,65.22],[-74.55,65.81],[-75.66,67.03],[-68.77,69.82]]]},\"properties\":{\"x\": -71, \"y\": 65}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[136.27,65.8],[137.78,64.03],[140.03,59.56],[139.48,56.48],[133.64,62.44],[129.67,69.6],[136.27,65.8]]]},\"properties\":{\"x\": 135, \"y\": 65}}]}", class = c("json", "geo_json"))

poly_geo_list <- geojson_list(poly_geo_json)
poly_spdf <- geojson_sp(poly_geo_json)
poly_sp <- as(poly_spdf, "SpatialPolygons")

if (has_sf) {
  poly_sf <- st_as_sf(poly_spdf)
  poly_sfc <- st_geometry(poly_sf)
}

test_that("ms_points works with defaults", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-78.4154562738861,-53.95000746272258]},\"properties\":{\"x\":-78,\"y\":-53,\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-70.8687480648099,65.19505422895163]},\"properties\":{\"x\":-71,\"y\":65,\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[135.65518268439885,63.10517782011297]},\"properties\":{\"x\":135,\"y\":65,\"rmapshaperid\":2}}\n]}", class = c("json", "geo_json"))

  expected_sp <- geojson_sp(expected_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equal(ms_points(poly_geo_json), expected_json)
  expect_equal(ms_points(unclass(poly_geo_json)), expected_json)
  expect_equal(ms_points(poly_geo_list), geojson_list(expected_json))
  expect_equal(ms_points(poly_spdf), expected_sp)
  expect_equal(ms_points(poly_sp), as(expected_sp, "SpatialPoints"))

  if (has_sf) {
    expect_equal(ms_points(poly_sf), st_as_sf(expected_sp))
    expect_equal(ms_points(poly_sfc), st_as_sfc(expected_sp))
  }
})

test_that("ms_points works with location=centroid", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-78.4154562738861,-53.95000746272258]},\"properties\":{\"x\":-78,\"y\":-53,\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-70.8687480648099,65.19505422895163]},\"properties\":{\"x\":-71,\"y\":65,\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[135.65518268439885,63.10517782011297]},\"properties\":{\"x\":135,\"y\":65,\"rmapshaperid\":2}}\n]}", class = c("json", "geo_json"))

  expected_sp <- geojson_sp(expected_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equal(ms_points(poly_geo_json, location = "centroid"), ms_points(poly_geo_json))
  expect_equal(ms_points(poly_geo_json, location = "centroid"), expected_json)
  expect_equal(ms_points(poly_geo_list, location = "centroid"), geojson_list(expected_json))
  expect_equal(ms_points(poly_spdf, location = "centroid"), expected_sp)

  if (has_sf) {
    expect_equal(ms_points(poly_sf, location = "centroid"), st_as_sf(expected_sp))
    expect_equal(ms_points(poly_sfc, location = "centroid"), st_as_sfc(expected_sp))
  }
})

test_that("ms_points works with location=inner", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-77.94495627388609,-54.35054796472695]},\"properties\":{\"x\":-78,\"y\":-53,\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-70.7792242552861,65.38990758263705]},\"properties\":{\"x\":-71,\"y\":65,\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[135.73366753288371,63.20605469121952]},\"properties\":{\"x\":135,\"y\":65,\"rmapshaperid\":2}}\n]}", class = c("json", "geo_json"))

  expected_sp <- geojson_sp(expected_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equal(ms_points(poly_geo_json, location = "inner"), expected_json)
  expect_equal(ms_points(poly_geo_list, location = "inner"), geojson_list(expected_json))
  expect_equal(ms_points(poly_spdf, location = "inner"), expected_sp)

  if (has_sf) {
    expect_equal(ms_points(poly_sf, location = "inner"), st_as_sf(expected_sp))
    expect_equal(ms_points(poly_sfc, location = "inner"), st_as_sfc(expected_sp))
  }
})

test_that("ms_points works with x and y", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-78,-53]},\"properties\":{\"x\":-78,\"y\":-53,\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-71,65]},\"properties\":{\"x\":-71,\"y\":65,\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[135,65]},\"properties\":{\"x\":135,\"y\":65,\"rmapshaperid\":2}}\n]}", class = c("json", "geo_json"))

  expected_sp <- geojson_sp(expected_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equal(ms_points(poly_geo_json, x = "x", y = "y"), expected_json)
  expect_equal(ms_points(poly_geo_list, x = "x", y = "y"), geojson_list(expected_json))
  expect_equal(ms_points(poly_spdf, x = "x", y = "y"), expected_sp)

  if (has_sf) {
    expect_equal(ms_points(poly_sf, x = "x", y = "y"), st_as_sf(expected_sp))
  }
})

test_that("ms_points fails correctly", {
  expect_error(ms_points(poly_geo_json, location = "foo"), "location must be 'centroid' or 'inner'")
  expect_error(ms_points(poly_geo_json, location = "inner", x = "x", y = "y"),
               "You have specified both a location and x/y for point placement")
  expect_error(ms_points(poly_geo_json, location = "inner", x = "x"),
               "You have specified both a location and x/y for point placement")
  expect_error(ms_points(poly_geo_json, location = "inner", y = "y"),
               "You have specified both a location and x/y for point placement")
  expect_error(ms_points(poly_geo_json, x = "x"), "Only one of x/y pair found")
  expect_error(ms_points(poly_geo_json, y = "y"), "Only one of x/y pair found")
  expect_error(ms_points(poly_geo_json, force_FC = "true"),
               "force_FC must be TRUE or FALSE")
})
