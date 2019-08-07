context("ms_simplify")

suppressPackageStartupMessages({
  library("geojsonio")
  library("geojsonlint")
  library("sf")
})

poly <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-7.1549869,45.4449053],[-7.6245498,37.9890775],[-7.5290969,38.0423402],[-3.3235845,40.588151],[-7.344442,37.6863061],[1.8042184,41.0097841],[3.7578538,38.7756389],[1.8629117,35.5400723],[-6.3787009,28.8026166],[-8.3144042,35.6271496],[-9.3413257,34.4122375],[-7.8818739,37.2784218],[-10.970619,35.0652943],[-7.855486,37.303094],[-17.6800154,33.0680873],[-11.4987062,37.7759151],[-16.8542278,41.7896373],[-9.6292336,41.0325088],[-8.3619054,39.5168442],[-8.1027301,39.7855456],[-7.1549869,45.4449053]]]},"properties":{}}]}', class = c("json", "geo_json"))

line <- structure('{"type":"FeatureCollection", "features": [{"type":"Feature","geometry":{"type":"LineString","coordinates":[[-146.030845,-17.697398],[-138.8493372,-17.938697],[-137.5671055,-18.9589785],[-146.3153242,-20.8865269],[-142.9518755,-24.359833],[-147.6422817,-20.9477376],[-146.6957993,-24.7101963],[-147.696223,-21.1162469],[-156.2250727,-21.2045764],[-150.6399109,-15.4286993],[-146.030845,-17.697398]]},"properties":{}}]}', class = c("json", "geo_json"))

line_list <- structure(geojson_list(line), class = "geo_list")

line_spdf <- geojson_sp(line)
line_sp <- as(line_spdf, "SpatialLines")

poly_spdf <- geojson_sp(poly)
poly_sp <- as(poly_spdf, "SpatialPolygons")

poly_list <- structure(geojson_list(poly), class = "geo_list")

test_that("ms_simplify.geo_json and character works with defaults", {
  default_simplify_json <- ms_simplify(poly)

  expect_is(default_simplify_json, "geo_json")
  expect_equal(clean_ws(default_simplify_json),
               clean_ws(structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-7.1549869,45.4449053],[-7.344442,37.6863061],[1.8629117,35.5400723],[-6.3787009,28.8026166],[-9.6292336,41.0325088],[-7.1549869,45.4449053]]]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))))
  expect_equal(default_simplify_json, ms_simplify(unclass(poly))) # character
  expect_true(geojsonlint::geojson_validate(default_simplify_json))

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_simplify(poly, sys = TRUE), "geo_json")
})

test_that("ms_simplify.geo_json with keep=1 returns same as input", {
  expect_equal(geojson_list(poly)$features[[1]]$geometry,
               geojson_list(ms_simplify(poly, keep = 1))$features[[1]]$geometry)
})

test_that("ms_simplify.geo_json works with different methods", {
  vis_simplify_json <- ms_simplify(poly, method = "vis", weighting = 0)
  dp_simplify_json <- ms_simplify(poly, method = "dp")

  expect_is(vis_simplify_json, "geo_json")
  expect_equal(clean_ws(vis_simplify_json),
               clean_ws(structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-7.1549869,45.4449053],[1.8629117,35.5400723],[-6.3787009,28.8026166],[-7.1549869,45.4449053]]]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))))
  expect_is(dp_simplify_json, "geo_json")
  expect_equal(clean_ws(dp_simplify_json),
               clean_ws(structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-7.1549869,45.4449053],[-6.3787009,28.8026166],[-17.6800154,33.0680873],[-7.1549869,45.4449053]]]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))))
})

test_that("ms_simplify.geo_list works with defaults", {
  default_simplify_geo_list <- ms_simplify(poly_list)

  expect_is(default_simplify_geo_list, "geo_list")
  expect_equal(default_simplify_geo_list$features,
               list(structure(list(type = "Feature", geometry = structure(list(
                 type = "Polygon",
                 coordinates = list(
                   list(list(-7.1549869, 45.4449053),
                        list(-7.344442, 37.6863061),
                        list(1.8629117, 35.5400723),
                        list(-6.3787009, 28.8026166),
                        list(-9.6292336, 41.0325088),
                        list(-7.1549869, 45.4449053)))),
                 .Names = c("type", "coordinates")),
                 properties = structure(list(rmapshaperid = 0L),
                                        .Names = "rmapshaperid")),
                 .Names = c("type", "geometry", "properties")))
  )

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_simplify(poly_list, sys = TRUE), "geo_list")
})

test_that("ms_simplify.SpatialPolygons works with defaults", {
  default_simplify_spdf <- ms_simplify(poly_spdf)
  default_simplify_sp <- ms_simplify(poly_sp)

  expect_is(default_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_is(default_simplify_sp, "SpatialPolygons")
  expect_equivalent(default_simplify_sp, as(default_simplify_spdf, "SpatialPolygons"))
  expect_equal(default_simplify_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(-7.1549869, -7.344442, 1.8629117, -6.3787009, -9.6292336,
                           -7.1549869, 45.4449053, 37.6863061, 35.5400723, 28.8026166, 41.0325088,
                           45.4449053), .Dim = c(6L, 2L)))
  expect_true(rgeos::gIsValid(default_simplify_spdf))

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_simplify(poly_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
  expect_is(ms_simplify(poly_sp, sys = TRUE), "SpatialPolygons")
})

test_that("simplify.SpatialPolygonsDataFrame works with other methods", {
  vis_simplify_spdf <- ms_simplify(poly_spdf, method = "vis", weighting = 0)
  dp_simplify_spdf <- ms_simplify(poly_spdf, method = "dp")

  expect_is(vis_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_equal(vis_simplify_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(-7.1549869, 1.8629117, -6.3787009, -7.1549869, 45.4449053,
                           35.5400723, 28.8026166, 45.4449053), .Dim = c(4L, 2L)))
  expect_true(rgeos::gIsValid(vis_simplify_spdf))

  expect_is(dp_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_equal(dp_simplify_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(-7.1549869, -6.3787009, -17.6800154, -7.1549869,
                           45.4449053, 28.8026166, 33.0680873, 45.4449053),
                         .Dim = c(4L, 2L)))
  expect_true(rgeos::gIsValid(dp_simplify_spdf))
})

multipoly <- structure('{
"type": "MultiPolygon",
"coordinates": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0],
[102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0],
[100.0, 0.0]]]]
} ', class = c("json", "geo_json"))
multi_spdf <- geojsonio::geojson_sp(multipoly)

test_that("exploding works with geo_json", {
  out <- ms_simplify(multipoly, keep_shapes = TRUE, explode = FALSE)
  expect_equal(clean_ws(out),
               clean_ws(structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))))
  out <- ms_simplify(multipoly, keep_shapes = TRUE, explode = TRUE)
  expect_equal(clean_ws(out),
               clean_ws(structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))))
})

test_that("exploding works with SpatialPolygonsDataFrame", {
  out <- ms_simplify(multi_spdf, keep_shapes = TRUE)
  expect_equal(length(out@polygons), 1)
  out <- ms_simplify(multi_spdf, keep_shapes = TRUE, explode = TRUE)
  # Temporarily remove due to bug in GDAL 2.1.0
  expect_equal(length(out@polygons), 2)
})

test_that("ms_simplify fails with invalid geo_json", {
  expect_error(ms_simplify('{foo: "bar"}'), "Input is not valid geojson")
})

test_that("ms_simplify fails correctly", {
  expect_error(ms_simplify(poly, keep = 0), "keep must be > 0 and <= 1")
  expect_error(ms_simplify(poly, keep = 1.01), "keep must be > 0 and <= 1")
  expect_error(ms_simplify(poly, method = "foo"), "method should be one of")
})

multipoly <- structure('
{
  "type": "FeatureCollection",
  "features": [
  {
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates":[[[-152.3433185,-51.1400329],[-144.9301966,-51.453939],[-151.7435349,-55.6886215],[-147.8559534,-56.2197224],[-136.9430457,-58.449077],[-149.8608625,-56.9673288],[-142.1320457,-59.7694693],[-145.8290265,-64.392506],[-153.3221574,-65.1360902],[-159.8131297,-63.4417056],[-168.2902719,-61.7109737],[-159.4759954,-57.921224],[-156.0772551,-56.6289602],[-168.1285495,-57.1318526],[-160.5989367,-56.1920838],[-168.8213077,-55.2001918],[-167.0773342,-52.2966425],[-153.1392916,-55.3074558],[-156.5065133,-47.5779291],[-153.0625187,-50.9189549],[-152.3433185,-51.1400329]]]
  },
  "properties": {

  }
  },
  {
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates": [[[70.6011604,-46.7259373],[73.7751031,-51.6831692],[84.6589604,-51.5355248],[86.6562583,-52.0080875],[85.27707,-55.8454444],[73.8683796,-55.8846499],[67.4990576,-59.4842469],[67.4470766,-53.7361917],[62.1855019,-53.3722205],[65.6152052,-48.4648198],[70.6011604,-46.7259373]]]
  },
  "properties": {

  }
  },
  {
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates": [[[-167.6460128,-2.4870059],[-164.0218557,4.0942137],[-164.3485321,1.2289566],[-162.3875504,3.219013],[-161.9762018,-7.9484803],[-167.6460128,-2.4870059]]]
  },
  "properties": {}
  }
  ]
  }', class = c("json", "geo_json"))

multipoly_list <- geojson_list(multipoly)
multipoly_spdf <- geojson_sp(multipoly)

test_that("ms_simplify works with drop_null_geometries", {
  out_drop <- ms_simplify(multipoly, keep_shapes = FALSE, drop_null_geometries = TRUE)
  expect_equal(clean_ws(out_drop),
               clean_ws(structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-152.3433185,-51.1400329],[-142.1320457,-59.7694693],[-153.3221574,-65.1360902],[-168.2902719,-61.7109737],[-152.3433185,-51.1400329]]]},"properties":{"rmapshaperid":0}}
]}', class = c("json", "geo_json"))))
  out_nodrop <- ms_simplify(multipoly, keep_shapes = FALSE, drop_null_geometries = FALSE)
  expect_equal(clean_ws(out_nodrop),
               clean_ws(structure('{"type":"FeatureCollection", "features": [
{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-152.3433185,-51.1400329],[-142.1320457,-59.7694693],[-153.3221574,-65.1360902],[-168.2902719,-61.7109737],[-152.3433185,-51.1400329]]]},"properties":{"rmapshaperid":0}},
{"type":"Feature","geometry":null,"properties":{"rmapshaperid":1}},
{"type":"Feature","geometry":null,"properties":{"rmapshaperid":2}}
]} ', class = c("json", "geo_json"))))
})

test_that("ms_simplify.SpatialPolygonsDataFrame works keep_shapes = FALSE and ignores drop_null_geometries", {
  out <- ms_simplify(multipoly_spdf, keep_shapes = FALSE, drop_null_geometries = TRUE)
  expect_equal(length(out@polygons), 1)
  out_nodrop <- ms_simplify(multipoly_spdf, keep_shapes = FALSE, drop_null_geometries = FALSE)
  expect_equivalent(out, out_nodrop)
})

test_that("ms_simplify works with lines", {
  expected_json <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"LineString","coordinates":[[-146.030845,-17.697398],[-147.696223,-21.1162469],[-156.2250727,-21.2045764],[-150.6399109,-15.4286993],[-146.030845,-17.697398]]},"properties":{"rmapshaperid":0}}]}', class = c("json", "geo_json"))

  expect_equal(clean_ws(ms_simplify(line, keep = 0.1)), clean_ws(expected_json))
  expect_equal(ms_simplify(line_list, keep = 0.1), geojson_list(expected_json), tolerance = 1e-7)
  expect_equivalent(ms_simplify(line_spdf, keep = 0.1), geojson_sp(expected_json))
  expect_equivalent(ms_simplify(line_sp, keep = 0.1), as(ms_simplify(line_spdf, keep = 0.1), "SpatialLines"))
})

test_that("ms_simplify works correctly when all geometries are dropped", {
  expect_error(ms_simplify(multipoly_spdf, keep = 0.001), "Cannot convert result to a Spatial\\* object")
  expect_equal(clean_ws(ms_simplify(multipoly, keep = 0.001)),
               clean_ws(structure("{\"type\":\"GeometryCollection\",\"geometries\":[\n\n]}", class = c("json", "geo_json"))))
  expect_equal(ms_simplify(multipoly_list, keep = 0.001), structure(list(type = "GeometryCollection", geometries = list()), .Names = c("type", "geometries"), class = "geo_list", from = "json"))
})

test_that("snap_interval works", {
  poly <- structure('{"type":"FeatureCollection",
  "features":[
                  {"type":"Feature",
                  "properties":{},
                  "geometry":{"type":"Polygon","coordinates":[[
                  [101,2],[101,3],[103,3],[103,2],[102,2],[101,2]
                  ]]}}
                  ,{"type":"Feature",
                  "properties":{},
                  "geometry":{"type":"Polygon","coordinates":[[
                  [101,1],[101,2],[102,1.9],[103,2],[103,1],[101,1]
                  ]]}}]}', class = c("json", "geo_json"))

  poly_not_snapped <- ms_simplify(poly, keep = 0.8, snap = TRUE, snap_interval = 0.09)
  expect_equal(clean_ws(poly_not_snapped),
               clean_ws(structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[101,3],[103,3],[103,2],[102,2],[101,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[102,1.9],[103,2],[103,1],[101,1],[101,2]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))))

  poly_snapped <- ms_simplify(poly, keep = 0.8, snap = TRUE, snap_interval = 0.11)
  expect_equal(clean_ws(poly_snapped), clean_ws(structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[101,3],[103,3],[103,2],[102,2],[101,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[102,2],[103,2],[103,1],[101,1],[101,2]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json","geo_json"))))
})

test_that("ms_simplify works with very small values of 'keep", {
  expect_s3_class(ms_simplify(poly, keep = 0.0001), "geo_json")
})


# SF ----------------------------------------------------------------------

test_that("ms_simplify works with sf", {
  multipoly_sf <- st_as_sf(multipoly_spdf)
  line_sf <- st_as_sf(line_spdf)
  expect_is(ms_simplify(multipoly_sf), c("sf", "data.frame"))
  expect_is(ms_simplify(line_sf), c("sf", "data.frame"))

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_simplify(multipoly_sf, sys = TRUE), c("sf", "data.frame"))
})



test_that("ms_simplify works with sfc", {
  poly_sfc <- st_as_sfc(poly_sp)
  line_sfc <- st_as_sfc(line_sp)
  expect_is(ms_simplify(poly_sfc), c("sfc_POLYGON", "sfc"))
  expect_is(ms_simplify(line_sfc), c("sfc_LINESTRING", "sfc"))

  skip_if_not(has_sys_mapshaper())
  expect_is(ms_simplify(poly_sfc, sys = TRUE), c("sfc_POLYGON", "sfc"))
})

xs <- st_polygon(list(cbind(approx(c(0, 0, 1, 1, 0))$y,
                            approx(c(0, 1, 1, 0, 0))$y)))

test_that("ms_simplify works with various column types", {
  xsf <- st_sf(geometry = st_sfc(xs, xs + 2, xs + 3), a = 1:3)
  nr <- dim(xsf)[1]
  various_types <- list(
    date = Sys.Date() + seq_len(nr),
    time = Sys.time() + seq_len(nr),
    cpx = complex(nr),
    #      rw = raw(nr),
    lst = replicate(nr, "a", simplify = FALSE)
  )
  for (itype in seq_along(various_types)) {
    xsf$check_me <- various_types[[itype]]
    context(typeof(various_types[[itype]]))
    simp_xsf <- ms_simplify(xsf)
    expect_is(simp_xsf, c("sf", "data.frame"))
    ## not currently working for POSIXct
    #expect_identical(simp_xsf$check_me, various_types[[itype]])
  }

  ## raw special case
  xsf$check_me <- raw(nr)
  expect_warning(simp_xsf <- ms_simplify(xsf), "NAs introduced by coercion")
})
