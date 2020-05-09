context("apply_mapshaper_commands")

geojson <- '{"type":"FeatureCollection",
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
  ]]}}]}'

test_that("apply_mapshaper_commands doesn't delete local file", {
  skip_if_not(has_sys_mapshaper())
  testfile <- tempfile(fileext = ".geojson")
  writeLines(geojson, testfile)
  apply_mapshaper_commands(testfile, "--dissolve", force_FC = FALSE, sys = TRUE)
  expect_true(file.exists(testfile))
  unlink(testfile)
})

