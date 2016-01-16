context("ms_filter")
library(geojsonio)

poly_geo_json <- structure('{"type":"FeatureCollection",
  "features":[
 {"type":"Feature",
 "properties":{"foo": null, "bar": 1, "baz": 10, "bat": true},
 "geometry":{"type":"Polygon","coordinates":[[
 [102,2],[102,3],[103,3],[103,2],[102,2]
 ]]}}
 ,{"type":"Feature",
 "properties":{"foo": "b", "bar": 2, "baz": 20, "bat": true},
 "geometry":{"type":"Polygon","coordinates":[[
 [103,3],[104,3],[104,2],[103,2],[103,3]
 ]]}},
 {"type":"Feature",
 "properties":{"foo": "c", "bar": 3, "baz": 30, "bat": false},
 "geometry":{"type":"Polygon","coordinates":[[
 [102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]
 ]]}}]}', class = c("json", "geo_json"))

poly_geo_list <- geojson_list(poly_geo_json)

poly_spdf <- geojson_sp(poly_geo_json)

test_that("ms_filter works with all classes", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"foo\":\"b\",\"bar\":2,\"baz\":20,\"bat\":true,\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[103,3],[104,3],[104,2],[103,2],[103,3]]]}}]}", class = c("json", "geo_json"))

  expect_equal(ms_filter(unclass(poly_geo_json), "foo == 'b'"), expected_json)
  expect_equal(ms_filter(poly_geo_json, "foo == 'b'"), expected_json)
  expect_equal(ms_filter(poly_geo_list, "foo == 'b'"), geojson_list(expected_json))
  expect_equal(nrow(ms_filter(poly_spdf, "foo == 'b'")@data), 1)
  expect_equal(ms_filter(poly_spdf, "foo == 'b'")@data$foo, factor("b"))
  expect_equal(ms_filter(poly_spdf, "foo == 'b'")@polygons[[1]]@Polygons[[1]]@coords,
               geojson_sp(expected_json)@polygons[[1]]@Polygons[[1]]@coords)
})


test_that("make_js_expression works", {
  expect_equal(make_js_expression("is.na(foo)"), "foo === null")
  expect_equal(make_js_expression("!is.na(foo)"), "foo !== null")
  expect_equal(make_js_expression("foo == 'bar'"), "foo === 'bar'")
  expect_equal(make_js_expression("foo != 'bar'"), "foo !== 'bar'")
  expect_equal(make_js_expression(c("foo > 1", "bar == 2")), "(foo > 1) && (bar === 2)")
  expect_equal(make_js_expression(c("!is.na(foo)", "bar == 2 | baz > 6")), "(foo !== null) && (bar === 2 || baz > 6)")
  expect_equal(make_js_expression("foo == TRUE | bar == FALSE"), "foo === true || bar === false")
})

test_that("lots of logical expressions work", {
  expect_equal(ms_filter(poly_geo_json, "is.na(foo) | baz == 20"), structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"foo\":null,\"bar\":1,\"baz\":10,\"bat\":true,\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[103,3],[103,2],[102,2],[102,3],[103,3]]]}},\n{\"type\":\"Feature\",\"properties\":{\"foo\":\"b\",\"bar\":2,\"baz\":20,\"bat\":true,\"rmapshaperid\":1},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[103,3],[104,3],[104,2],[103,2],[103,3]]]}}]}", class = c("json", "geo_json")))
  expect_equal(ms_filter(poly_geo_json, c("bar > 1", "baz < 30")), structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"foo\":\"b\",\"bar\":2,\"baz\":20,\"bat\":true,\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[103,3],[104,3],[104,2],[103,2],[103,3]]]}}]}", class = c("json", "geo_json")))
  expect_equal(ms_filter(poly_geo_json, "bat == FALSE"), structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"foo\":\"c\",\"bar\":3,\"baz\":30,\"bat\":false,\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]]]}}]}", class = c("json", "geo_json")))
  expect_equal(ms_filter(poly_geo_json, c("baz > 20 | is.na(foo)", "bat == TRUE")), structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"foo\":null,\"bar\":1,\"baz\":10,\"bat\":true,\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[103,3],[103,2],[102,2],[102,3],[103,3]]]}}]}", class = c("json", "geo_json")))
  expect_equal(ms_filter(poly_geo_json, "bar + baz == 22"), structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"foo\":\"b\",\"bar\":2,\"baz\":20,\"bat\":true,\"rmapshaperid\":0},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[103,3],[104,3],[104,2],[103,2],[103,3]]]}}]}", class = c("json", "geo_json")))
})


# test_that("ms_lines works with fields specified", {
#   expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"TYPE\":2,\"rmapshaperid\":0},\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]}},\n{\"type\":\"Feature\",\"properties\":{\"TYPE\":0,\"rmapshaperid\":1},\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2],[102,3],[103,3]]}},\n{\"type\":\"Feature\",\"properties\":{\"TYPE\":0,\"rmapshaperid\":2},\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2],[103,2]]}},\n{\"type\":\"Feature\",\"properties\":{\"TYPE\":0,\"rmapshaperid\":3},\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]]}}]}", class = c("json", "geo_json"))
#
#   expect_equal(ms_lines(poly_geo_json, "foo"), expected_json)
#   expect_equal(ms_lines(poly_geo_list, "foo"), geojson_list(expected_json))
#   expect_equal(ms_lines(poly_spdf, "foo"), geojson_sp(expected_json))
# })
#
# test_that("ms_lines errors correctly", {
#   expect_error(ms_lines("foo"), "Input is not valid geojson")
#   expect_error(ms_lines(poly_geo_json, "bar"), "Unknown data field: bar")
#   expect_error(ms_lines(poly_spdf, "bar"), "not all fields specified exist in input data")
#   expect_error(ms_lines(poly_geo_json, 1), "fields must be a character vector")
#   expect_error(ms_lines(poly_geo_json, force_FC = "true"), "force_FC must be TRUE or FALSE")
# })
