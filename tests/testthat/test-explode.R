context("ms_explode")

js <- structure('{
"type": "MultiPolygon",
"coordinates": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0],
[102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0],
[100.0, 0.0]]]]
} ', class = c("json", "geo_json"))

test_that("ms_explode.geo_json works", {
  out <- ms_explode(js)
  expect_is(out, "geo_json")
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]}},\n{\"type\":\"Feature\",\"properties\":{\"rmapshaperid\":1},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]}}]}", class = c("json", "geo_json")))
})

test_that("ms_explode.SpatialPolygonsDataFrame works", {
  spdf <- rgdal::readOGR(js, layer='OGRGeoJSON', verbose=FALSE)
  out <- ms_explode(spdf)
  expect_is(out, "SpatialPolygonsDataFrame")
  expect_equal(length(out@polygons), 2)
  sp_dis <- sp::disaggregate(spdf)
  expect_equal(lapply(out@polygons, function(x) x@Polygons[[1]]@coords),
               lapply(sp_dis@polygons, function(x) x@Polygons[[1]]@coords))
})