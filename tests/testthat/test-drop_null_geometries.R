context("drop_null_geometries")
library(geojsonio)

poly_geo_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-76.3,-49.68],[-75.53,-51.13],[-74.71,-56.89],[-84.11,-57.09],[-77.9,-50.62],[-84.12,-49.59],[-76.3,-49.68]]]},\"properties\":{\"x\": -78, \"y\": -53}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-68.77,69.82],[-66.26,62.96],[-74.22,60.87],[-74.12,65.22],[-74.55,65.81],[-75.66,67.03],[-68.77,69.82]]]},\"properties\":{\"x\": -71, \"y\": 65}},{\"type\":\"Feature\",\"geometry\":{},\"properties\":{\"x\": 135, \"y\": 65}}]}", class = c("json", "geo_json"))

poly_geo_list <- geojson_list(poly_geo_json)

test_that("drop_null_geometries_works", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-76.3,-49.68],[-75.53,-51.13],[-74.71,-56.89],[-84.11,-57.09],[-77.9,-50.62],[-84.12,-49.59],[-76.3,-49.68]]]},\"properties\":{\"x\":-78,\"y\":-53,\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-68.77,69.82],[-66.26,62.96],[-74.22,60.87],[-74.12,65.22],[-74.55,65.81],[-75.66,67.03],[-68.77,69.82]]]},\"properties\":{\"x\":-71,\"y\":65,\"rmapshaperid\":1}}\n]}", class = c("json",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  "geo_json"))

  expect_equal(drop_null_geometries(poly_geo_json), expected_out)
  out_list <- drop_null_geometries(poly_geo_list)
  expect_equal(length(out_list$features), 2)
})
