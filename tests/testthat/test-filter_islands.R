context("ms_filter_islands")
library(geojsonio)

poly <- structure("{\"type\":\"FeatureCollection\",
\"features\":[{\"type\":\"Feature\",\"roperties\":{\"rmapshaperid\":0},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}},
{\"type\":\"Feature\",\"properties\":{\"rmapshaperid\":1},
\"geometry\":{\"type\":\"Polygon\",
\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]}}]}",
class = c("json", "geo_json"))

test_that("ms_filter_islands works with all classes", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}}]}", class = c("json", "geo_json"))
  expect_equal(ms_filter_islands(poly, min_area = 12391399903), expected_json)
  expect_equal(ms_filter_islands(geojson_list(poly), min_area = 12391399903),
               geojson_list(expected_json))
  out_sp <- ms_filter_islands(geojson_sp(poly), min_area = 12391399903)
  expect_equal(length(out_sp@polygons[[1]]@Polygons), 1)
  expect_equal(out_sp@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(102, 102, 104, 104, 102, 2, 4, 4, 2, 2), .Dim = c(5L, 2L)))
})