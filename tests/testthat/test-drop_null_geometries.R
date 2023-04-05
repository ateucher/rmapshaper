test_that("drop_null_geometries_works", {
poly_geojson <-   structure(
  '{"type":"FeatureCollection",
    "features":[{
    "type":"Feature",
    "geometry":{"type":"Point","coordinates":[1,1]},
    "properties":{"x":1}},{
    "type":"Feature",
    "geometry":{},
    "properties":{"x":2}}]}',
  class = c("geojson", "json")
)
expect_snapshot_value(drop_null_geometries(poly_geojson), style = "json2")
})
