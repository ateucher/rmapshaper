context("drop_null_geometries")
suppressPackageStartupMessages(library("geojsonio"))

poly_geojson <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-76.3,-49.68],[-75.53,-51.13],[-74.71,-56.89],[-84.11,-57.09],[-77.9,-50.62],[-84.12,-49.59],[-76.3,-49.68]]]},\"properties\":{\"x\":-78,\"y\":-53}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-68.77,69.82],[-66.26,62.96],[-74.22,60.87],[-74.12,65.22],[-74.55,65.81],[-75.66,67.03],[-68.77,69.82]]]},\"properties\":{\"x\":-71,\"y\":65}},{\"type\":\"Feature\",\"geometry\":{},\"properties\":{\"x\":135,\"y\":65}}]}", class = c("geojson", "json"))

test_that("drop_null_geometries_works", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-76.3,-49.68],[-75.53,-51.13],[-74.71,-56.89],[-84.11,-57.09],[-77.9,-50.62],[-84.12,-49.59],[-76.3,-49.68]]]},\"properties\":{\"x\":-78,\"y\":-53,\"rmapshaperid\":0}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-68.77,69.82],[-66.26,62.96],[-74.22,60.87],[-74.12,65.22],[-74.55,65.81],[-75.66,67.03],[-68.77,69.82]]]},\"properties\":{\"x\":-71,\"y\":65,\"rmapshaperid\":1}}]}", class = c("json","geojson"))

  expect_equivalent_json(drop_null_geometries(poly_geojson), expected_out)
})
