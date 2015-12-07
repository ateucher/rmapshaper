context("ms_filter_fields")
library(geojsonio)

poly <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\": 1, \"b\":2, \"c\": 3},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}}]}",
class = c("json", "geo_json"))

pts <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\":1,\"b\":2,\"c\":3},
\"geometry\":{\"type\":\"Point\",
\"coordinates\":[103,3]}}]}", class = c("json", "geo_json"))

lines <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",
\"properties\":{\"a\":1,\"b\":2,\"c\":3},
\"geometry\":{\"type\":\"LineString\",
\"coordinates\":[[102,2],[102,4],[104,4],[104,2],[102,2]]}}]}",
class = c("json", "geo_json"))

test_that("ms_filter_fields works with polygons", {
  expected_out <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"a\":1,\"b\":2},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}}]}", class = c("json", "geo_json"))
  expect_equal(ms_filter_fields(poly, c("a", "b")), expected_out)
})

