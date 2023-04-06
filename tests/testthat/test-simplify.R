poly_simp <- structure('{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-7.1549869,45.4449053],[-7.6245498,37.9890775],[-7.5290969,38.0423402],[-3.3235845,40.588151],[-7.344442,37.6863061],[1.8042184,41.0097841],[3.7578538,38.7756389],[1.8629117,35.5400723],[-6.3787009,28.8026166],[-8.3144042,35.6271496],[-9.3413257,34.4122375],[-7.8818739,37.2784218],[-10.970619,35.0652943],[-7.855486,37.303094],[-17.6800154,33.0680873],[-11.4987062,37.7759151],[-16.8542278,41.7896373],[-9.6292336,41.0325088],[-8.3619054,39.5168442],[-8.1027301,39.7855456],[-7.1549869,45.4449053]]]},"properties":{}}]}', class = c("geojson", "json"))
line_simp <- structure('{"type":"FeatureCollection", "features": [{"type":"Feature","geometry":{"type":"LineString","coordinates":[[-146.030845,-17.697398],[-138.8493372,-17.938697],[-137.5671055,-18.9589785],[-146.3153242,-20.8865269],[-142.9518755,-24.359833],[-147.6422817,-20.9477376],[-146.6957993,-24.7101963],[-147.696223,-21.1162469],[-156.2250727,-21.2045764],[-150.6399109,-15.4286993],[-146.030845,-17.697398]]},"properties":{}}]}', class = c("geojson", "json"))

line_simp_spdf <- GeoJSON_to_sp(line_simp)
line_simp_sp <- as(line_simp_spdf, "SpatialLines")

poly_simp_spdf <- GeoJSON_to_sp(poly_simp)
poly_simp_sp <- as(poly_simp_spdf, "SpatialPolygons")

multiple_poly_simp <- structure('
{
  "type": "FeatureCollection",
  "features": [
  {
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates":[[[-152.3433185,-51.1400329],[-144.9301966,-51.453939],[-151.7435349,-55.6886215],[-147.8559534,-56.2197224],[-136.9430457,-58.449077],[-149.8608625,-56.9673288],[-142.1320457,-59.7694693],[-145.8290265,-64.392506],[-153.3221574,-65.1360902],[-159.8131297,-63.4417056],[-168.2902719,-61.7109737],[-159.4759954,-57.921224],[-156.0772551,-56.6289602],[-168.1285495,-57.1318526],[-160.5989367,-56.1920838],[-168.8213077,-55.2001918],[-167.0773342,-52.2966425],[-153.1392916,-55.3074558],[-156.5065133,-47.5779291],[-153.0625187,-50.9189549],[-152.3433185,-51.1400329]]]
  },
  "properties": {}
  },{
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates": [[[70.6011604,-46.7259373],[73.7751031,-51.6831692],[84.6589604,-51.5355248],[86.6562583,-52.0080875],[85.27707,-55.8454444],[73.8683796,-55.8846499],[67.4990576,-59.4842469],[67.4470766,-53.7361917],[62.1855019,-53.3722205],[65.6152052,-48.4648198],[70.6011604,-46.7259373]]]
  },
  "properties": {}
  },{
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates": [[[-167.6460128,-2.4870059],[-164.0218557,4.0942137],[-164.3485321,1.2289566],[-162.3875504,3.219013],[-161.9762018,-7.9484803],[-167.6460128,-2.4870059]]]
  },
  "properties": {}
  }
  ]
  }', class = c("geojson", "json"))

multiple_poly_simp_spdf <- GeoJSON_to_sp(multiple_poly_simp)

multiple_poly_simp_sf <- st_as_sf(multiple_poly_simp_spdf)

test_that("ms_simplify.geojson and character works with defaults", {
  default_simplify_json <- ms_simplify(poly_simp)

  expect_s3_class(default_simplify_json, "geojson")
  expect_snapshot_value(default_simplify_json, style = "json2")
  expect_true(jsonify::validate_json(default_simplify_json))

  expect_equal(ms_simplify(poly_simp), default_simplify_json)

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_simplify(poly_simp, sys = TRUE), "geojson")
})

test_that("ms_simplify.geojson works with different methods", {
  vis_simplify_json <- ms_simplify(poly_simp, method = "vis", weighting = 0)
  dp_simplify_json <- ms_simplify(poly_simp, method = "dp")

  expect_s3_class(vis_simplify_json, "geojson")
  expect_snapshot_value(vis_simplify_json, style = "json2")
  expect_s3_class(dp_simplify_json, "geojson")
  expect_snapshot_value(dp_simplify_json, style = "json2")
})

test_that("ms_simplify.SpatialPolygons works with defaults", {
  default_simplify_spdf <- ms_simplify(poly_simp_spdf)
  default_simplify_sp <- ms_simplify(poly_simp_sp)

  expect_s4_class(default_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_s4_class(default_simplify_sp, "SpatialPolygons")
  expect_equivalent(default_simplify_sp, as(default_simplify_spdf, "SpatialPolygons"))
  expect_true(sf::st_is_valid(sf::st_as_sf(default_simplify_spdf)))

  skip_if_not(has_sys_mapshaper())
  expect_s4_class(ms_simplify(poly_simp_spdf, sys = TRUE), "SpatialPolygonsDataFrame")
  expect_s4_class(ms_simplify(poly_simp_sp, sys = TRUE), "SpatialPolygons")
})

test_that("simplify.SpatialPolygonsDataFrame works with other methods", {
  vis_simplify_spdf <- ms_simplify(poly_simp_spdf, method = "vis", weighting = 0)
  dp_simplify_spdf <- ms_simplify(poly_simp_spdf, method = "dp")

  expect_s4_class(vis_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_true(sf::st_is_valid(sf::st_as_sf(vis_simplify_spdf)))

  expect_s4_class(dp_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_true(sf::st_is_valid(sf::st_as_sf(dp_simplify_spdf)))
})

test_that("exploding works with geojson", {
  multipoly <- structure('{
"type": "MultiPolygon",
"coordinates": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0],
[102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0],
[100.0, 0.0]]]]
} ', class = c("geojson", "json"))
  multi_spdf <- GeoJSON_to_sp(multipoly)

  out <- ms_simplify(multipoly, keep_shapes = TRUE, explode = FALSE)
  expect_snapshot_value(out, style = "json2")
  out <- ms_simplify(multipoly, keep_shapes = TRUE, explode = TRUE)
  expect_snapshot_value(out, style = "json2")

  #SPDF
  out <- ms_simplify(multi_spdf, keep_shapes = TRUE)
  expect_equal(length(out@polygons), 1)
  out <- ms_simplify(multi_spdf, keep_shapes = TRUE, explode = TRUE)
  expect_equal(length(out@polygons), 2)
})

test_that("ms_simplify fails with invalid geojson", {
  expect_error(ms_simplify('{foo: "bar"}'), "Input is not valid geojson")
})

test_that("ms_simplify fails correctly", {
  expect_error(ms_simplify(poly_simp, keep = 0), "keep must be > 0 and <= 1")
  expect_error(ms_simplify(poly_simp, keep = 1.01), "keep must be > 0 and <= 1")
  expect_error(ms_simplify(poly_simp, method = "foo"), "method should be one of")
})

test_that("ms_simplify works with drop_null_geometries", {
  out_drop <- ms_simplify(multiple_poly_simp, keep_shapes = FALSE, drop_null_geometries = TRUE)
  expect_snapshot_value(out_drop, style = "json2")
  out_nodrop <- ms_simplify(multiple_poly_simp, keep_shapes = FALSE, drop_null_geometries = FALSE)
  expect_snapshot_value(out_nodrop, style = "json2")
})

test_that("ms_simplify.SpatialPolygonsDataFrame works keep_shapes = FALSE and ignores drop_null_geometries", {
  out <- ms_simplify(multiple_poly_simp_spdf, keep_shapes = FALSE, drop_null_geometries = TRUE)
  expect_equal(length(out@polygons), 1)
  out_nodrop <- ms_simplify(multiple_poly_simp_spdf, keep_shapes = FALSE, drop_null_geometries = FALSE)
  expect_equivalent(out, out_nodrop)
})

test_that("ms_simplify works with lines", {
  out_json <- ms_simplify(line_simp, keep = 0.1)

  expect_snapshot_value(out_json, style = "json2")
  expect_equivalent(ms_simplify(line_simp_spdf, keep = 0.1), GeoJSON_to_sp(out_json))
  expect_equivalent(ms_simplify(line_simp_sp, keep = 0.1), as(ms_simplify(line_simp_spdf, keep = 0.1), "SpatialLines"))
})

test_that("ms_simplify works correctly when all geometries are dropped", {
  expect_error(ms_simplify(multiple_poly_simp_spdf, keep = 0.001), "Cannot convert result to a Spatial\\* object")
  expect_snapshot_value(ms_simplify(multiple_poly_simp, keep = 0.001), style = "json2")
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
                  ]]}}]}', class = c("geojson", "json"))

  poly_not_snapped <- ms_simplify(poly, keep = 0.8, snap = TRUE, snap_interval = 0.09)
  expect_snapshot_value(poly_not_snapped, style = "json2")

  poly_snapped <- ms_simplify(poly, keep = 0.8, snap = TRUE, snap_interval = 0.11)
  expect_snapshot_value(poly_snapped, style = "json2")
})

test_that("ms_simplify works with very small values of 'keep", {
  expect_s3_class(ms_simplify(poly_simp, keep = 0.0001), "geojson")
})


# SF ----------------------------------------------------------------------

test_that("ms_simplify works with sf", {
  line_sf <- st_as_sf(line_simp_spdf)
  expect_s3_class(ms_simplify(multiple_poly_simp_sf), "sf")
  expect_s3_class(ms_simplify(line_sf), "sf")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_simplify(multiple_poly_simp_sf, sys = TRUE), "sf")
})



test_that("ms_simplify works with sfc", {
  poly_sfc <- st_as_sfc(poly_simp_sp)
  line_sfc <- st_as_sfc(line_simp_sp)
  expect_s3_class(ms_simplify(poly_sfc), "sfc_POLYGON")
  # don't simplify too much or goes to empty point
  expect_s3_class(ms_simplify(line_sfc, keep = 0.5), "sfc_LINESTRING")

  skip_if_not(has_sys_mapshaper())
  expect_s3_class(ms_simplify(poly_sfc, sys = TRUE), "sfc_POLYGON")
})


test_that("ms_simplify works with various column types", {
  xs <- st_polygon(list(cbind(approx(c(0, 0, 1, 1, 0))$y,
                              approx(c(0, 1, 1, 0, 0))$y)))
  xsf <- st_sf(geometry = st_sfc(xs, xs + 2, xs + 3), a = 1:3)

  nr <- dim(xsf)[1]
  various_types <- list(
    date = Sys.Date() + seq_len(nr)
    # time = Sys.time() + seq_len(nr)
    # complex(nr),
    # rw = raw(nr),
    # lst = replicate(nr, "a", simplify = FALSE)
  )
  for (itype in seq_along(various_types)) {
    xsf$check_me <- various_types[[itype]]
    simp_xsf <- ms_simplify(xsf)
    expect_s3_class(simp_xsf, "sf")
    ## not currently working for POSIXct
    expect_equal(simp_xsf$check_me, various_types[[itype]], tolerance = 1)
  }

  ## raw special case
  # xsf$check_me <- raw(nr)
  # expect_warning(simp_xsf <- ms_simplify(xsf), "NAs introduced by coercion")
})


# units -------------------------------------------------------------------

test_that("ms_simplify works with sf objects containing units", {
  multiple_poly_simp_sf$area = sf::st_area(multiple_poly_simp_sf)
  expect_warning(multipoly_sf_simple <- ms_simplify(multiple_poly_simp_sf), "units")
  expect_s3_class(multipoly_sf_simple, "sf")
  expect_type(multipoly_sf_simple$area, "double")
})
