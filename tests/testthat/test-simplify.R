context("ms_simplify")

suppressPackageStartupMessages({
  library("geojsonio")
  library("geojsonlint")
})

has_sf <- suppressPackageStartupMessages(require("sf", quietly = TRUE))

poly <- structure('{
  "type": "Feature",
"properties": {},
"geometry": {
"type": "Polygon",
"coordinates": [
[
  [52.8658, -44.7219],
  [53.7702, -40.4873],
  [54.5983, -38.9206],
  [54.3694, -40.2055],
  [55.3204, -37.5579],
  [56.2757, -37.917],
  [55.8025, -39.974],
  [56.184, -40.6443],
  [56.0527, -41.428],
  [55.8639, -41.8601],
  [55.2698, -43.3478],
  [53.2038, -45.3591],
  [58.7924, -40.5458],
  [59.3436, -40.8043],
  [61.0835, -40.7529],
  [55.8822, -44.2364],
  [56.252, -44.1525],
  [58.0202, -43.634],
  [58.6638, -44.2017],
  [53.0884, -45.7021],
  [61.6699, -45.0678],
  [62.737, -46.2841],
  [55.7763, -46.2637],
  [61.5985, -48.0536],
  [55.4919, -46.7674],
  [55.3808, -46.885],
  [61.3726, -50.3026],
  [54.3448, -46.7941],
  [56.1968, -48.2469],
  [58.3038, -50.4299],
  [58.1317, -51.1977],
  [55.4059, -48.478],
  [53.9739, -47.2032],
  [56.8275, -50.6531],
  [54.9742, -49.1184],
  [54.3321, -48.2222],
  [53.2685, -46.5573],
  [53.5411, -47.2954],
  [53.0315, -46.4398],
  [54.0485, -50.8807],
  [52.799, -45.9386],
  [54.385, -55.3905],
  [53.3764, -54.4511],
  [53.1668, -51.5554],
  [52.7066, -46.8397],
  [51.5802, -52.7235],
  [52.0329, -49.5677],
  [50.0123, -54.9834],
  [50.1747, -52.1814],
  [49.0098, -52.3641],
  [52.6261, -45.9815],
  [50.6588, -48.7081],
  [50.5593, -48.1831],
  [47.7777, -50.7152],
  [52.5873, -45.8944],
  [52.6129, -45.8691],
  [49.175, -48.3844],
  [45.4671, -49.9292],
  [49.5584, -47.4359],
  [43.9643, -49.163],
  [52.7068, -45.7639],
  [43.2278, -47.1908],
  [45.1936, -46.5388],
  [50.1948, -46.0062],
  [46.7929, -45.9982],
  [44.2366, -45.5022],
  [51.6188, -45.6201],
  [48.4755, -45.1388],
  [49.6271, -45.2296],
  [47.1939, -44.7799],
  [43.7748, -43.6074],
  [48.9974, -44.2912],
  [48.3348, -43.8854],
  [52.0881, -45.385],
  [50.2184, -44.2319],
  [48.2389, -42.4925],
  [50.622, -44.0168],
  [50.327, -43.5207],
  [48.0804, -41.2784],
  [46.7767, -38.3542],
  [48.347, -40.2708],
  [49.0358, -40.5943],
  [48.9158, -39.8798],
  [49.6307, -40.6159],
  [51.1783, -42.3294],
  [52.4858, -45.0418],
  [50.7531, -40.0718],
  [52.44, -44.6258],
  [51.9617, -40.4054],
  [52.4043, -42.1861],
  [52.8658, -44.7219]
  ]
  ]
}
}', class = c("json", "geo_json"))

line <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[-145.823797406629,38.9089996693656],[-126.677279351279,-31.5765906963497],[55.2621808089316,-50.0359470024705],[-71.0863546840847,-63.6745454510674],[-85.5087857600302,-39.2010589549318],[61.3280264195055,-21.5475816093385],[111.265920912847,-12.028357652016],[86.1034004017711,-16.9480841606855],[44.9973328784108,70.142569988966],[-31.4937972743064,14.8874527355656],[26.4844715315849,31.5380143700168],[-58.8240995630622,56.9820305798203],[-63.5386520437896,60.1704036584124],[-108.767749238759,5.83010089583695],[78.9820377342403,53.8167471718043],[110.499991988763,82.2511944221333],[-177.570751542225,55.7854177616537],[-16.1148327123374,25.1785923494026],[117.501273332164,-53.2969523733482],[168.682718127966,2.06833674106747]]}}]}", class = c("json", "geo_json"))

line_list <- structure(geojson_list(line), class = "geo_list")

line_spdf <- geojson_sp(line)
line_sp <- as(line_spdf, "SpatialLines")

poly_spdf <- geojson_sp(poly)
poly_sp <- as(poly_spdf, "SpatialPolygons")

poly_list <- structure(geojson_list(poly), class = "geo_list")

test_that("ms_simplify.geo_json and character works with defaults", {
  default_simplify_json <- ms_simplify(poly)

  expect_is(default_simplify_json, "geo_json")
  expect_equal(default_simplify_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[53.7702,-40.4873],[61.0835,-40.7529],[58.0202,-43.634],[62.737,-46.2841],[55.7763,-46.2637],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))
  )
  expect_equal(default_simplify_json, ms_simplify(unclass(poly))) # character
  expect_true(geojsonlint::geojson_validate(default_simplify_json))
})

test_that("ms_simplify.geo_json with keep=1 returns same as input", {
  expect_equal(geojson_list(poly)$geometry,
               geojson_list(ms_simplify(poly, keep = 1))$features[[1]]$geometry)
})

test_that("ms_simplify.geo_json works with different methods", {
  vis_simplify_json <- ms_simplify(poly, method = "vis", weighting = 0)
  dp_simplify_json <- ms_simplify(poly, method = "dp")

  expect_is(vis_simplify_json, "geo_json")
  expect_equal(vis_simplify_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[62.737,-46.2841],[52.799,-45.9386],[50.0123,-54.9834],[49.0098,-52.3641],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))
  )
  expect_is(dp_simplify_json, "geo_json")
  expect_equal(dp_simplify_json, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[52.8658,-44.7219],[55.3204,-37.5579],[53.0884,-45.7021],[62.737,-46.2841],[52.799,-45.9386],[54.385,-55.3905],[46.7767,-38.3542],[52.8658,-44.7219]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))
  )
})

test_that("ms_simplify.geo_list works with defaults", {
  default_simplify_geo_list <- ms_simplify(poly_list)

  expect_is(default_simplify_geo_list, "geo_list")
  expect_equal(default_simplify_geo_list,
               structure(list(type = "FeatureCollection", features = list(structure(list(
                 type = "Feature", geometry = structure(list(type = "Polygon",
                                                             coordinates = list(list(list(52.8658, -44.7219), list(
                                                               53.7702, -40.4873), list(61.0835, -40.7529), list(
                                                                 58.0202, -43.634), list(62.737, -46.2841), list(55.7763,
                                                                                                                 -46.2637), list(52.8658, -44.7219)))), .Names = c("type",
                                                                                                                                                                   "coordinates")), properties = structure(list(rmapshaperid = 0L), .Names = "rmapshaperid")), .Names = c("type",
                                                                                                                                                                                                                                                                          "geometry", "properties")))), .Names = c("type", "features"), class = "geo_list", from = "json")
  )
})

test_that("ms_simplify.SpatialPolygons works with defaults", {
  default_simplify_spdf <- ms_simplify(poly_spdf)
  default_simplify_sp <- ms_simplify(poly_sp)

  expect_is(default_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_is(default_simplify_sp, "SpatialPolygons")
  expect_equal(default_simplify_sp, as(default_simplify_spdf, "SpatialPolygons"))
  expect_equal(default_simplify_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(52.8658, 53.7702, 61.0835, 58.0202, 62.737, 55.7763,
                           52.8658, -44.7219, -40.4873, -40.7529, -43.634,
                           -46.2841, -46.2637, -44.7219), .Dim = c(7L, 2L)))
  expect_true(rgeos::gIsValid(default_simplify_spdf))
})

test_that("simplify.SpatialPolygonsDataFrame works with other methods", {
  vis_simplify_spdf <- ms_simplify(poly_spdf, method = "vis", weighting = 0)
  dp_simplify_spdf <- ms_simplify(poly_spdf, method = "dp")

  expect_is(vis_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_equal(vis_simplify_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(52.8658, 62.737, 52.799, 50.0123, 49.0098, 52.8658,
                           -44.7219, -46.2841, -45.9386, -54.9834, -52.3641,
                           -44.7219), .Dim = c(6L, 2L)))
  expect_true(rgeos::gIsValid(vis_simplify_spdf))

  expect_is(dp_simplify_spdf, "SpatialPolygonsDataFrame")
  expect_equal(dp_simplify_spdf@polygons[[1]]@Polygons[[1]]@coords,
               structure(c(52.8658, 55.3204, 53.0884, 62.737, 52.799, 54.385,
                           46.7767, 52.8658, -44.7219, -37.5579, -45.7021,
                           -46.2841, -45.9386, -55.3905, -38.3542, -44.7219),
                         .Dim = c(8L, 2L)))
  expect_true(rgeos::gIsValid(dp_simplify_spdf))
})

multipoly <- structure('{
"type": "MultiPolygon",
"coordinates": [[[[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0],
[102.0, 2.0]]], [[[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0],
[100.0, 0.0]]]]
} ', class = c("json", "geo_json"))
multi_spdf <- rgdal::readOGR(multipoly, layer='OGRGeoJSON', verbose=FALSE)

test_that("exploding works with geo_json", {
  out <- ms_simplify(multipoly, keep_shapes = TRUE, explode = FALSE)
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))
  )
  out <- ms_simplify(multipoly, keep_shapes = TRUE, explode = TRUE)
  expect_equal(out, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[102,3],[103,3],[103,2],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json"))
  )
})

test_that("exploding works with SpatialPolygonsDataFrame", {
  out <- ms_simplify(multi_spdf, keep_shapes = TRUE)
  expect_equal(length(out@polygons), 1)
  out <- ms_simplify(multi_spdf, keep_shapes = TRUE, explode = TRUE)
  # Temporarily remove due to bug in GDAL 2.1.0
  #expect_equal(length(out@polygons), 2)
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
  "coordinates": [
  [
  [
  -152.823293088065,
  -51.6391932864114
  ],
  [
  -146.114812898716,
  -56.7281980257939
  ],
  [
  -145.393845889168,
  -60.2748771707085
  ],
  [
  -151.321371801353,
  -60.8221582100519
  ],
  [
  -147.583184774005,
  -64.5797609113241
  ],
  [
  -150.46620038689,
  -64.7784640584509
  ],
  [
  -154.521267388396,
  -60.7095358985367
  ],
  [
  -158.165576133759,
  -63.3347608880973
  ],
  [
  -161.704207823683,
  -63.0742460446259
  ],
  [
  -154.774197336172,
  -60.4935989121959
  ],
  [
  -152.823293088065,
  -51.6391932864114
  ]
  ]
  ]
  },
  "properties": {

  }
  },
  {
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates": [
  [
  [
  173.67169212182,
  85.4331134128574
  ],
  [
  176.67685080212,
  84.2764163171804
  ],
  [
  173.454124917594,
  83.1620648959886
  ],
  [
  175.121897184932,
  74.701785977225
  ],
  [
  172.312725601068,
  83.4442659169655
  ],
  [
  170.89119502252,
  79.2517365037372
  ],
  [
  168.133708914435,
  76.9229628212833
  ],
  [
  171.949857704415,
  83.8628808419096
  ],
  [
  171.190580512086,
  84.7888664407574
  ],
  [
  171.795991303468,
  87.6164256755121
  ],
  [
  173.67169212182,
  85.4331134128574
  ]
  ]
  ]
  },
  "properties": {

  }
  },
  {
  "type": "Feature",
  "geometry": {
  "type": "Polygon",
  "coordinates": [
  [
  [
  159.661223481221,
  -44.7793411145187
  ],
  [
  159.88753520634,
  -44.535445380596
  ],
  [
  162.640519872203,
  -45.5796730025464
  ],
  [
  160.973855016966,
  -45.2160499431973
  ],
  [
  161.257719833764,
  -47.8825409896705
  ],
  [
  160.545358806891,
  -48.0981283945151
  ],
  [
  156.145251478883,
  -50.594755853185
  ],
  [
  159.320952234816,
  -44.8480651992703
  ],
  [
  154.047901524855,
  -42.9327826524998
  ],
  [
  151.956344518026,
  -40.313731424249
  ],
  [
  159.661223481221,
  -44.7793411145187
  ]
  ]
  ]
  },
  "properties": {

  }
  }
  ]
  }
', class = c("json", "geo_json"))

multipoly_list <- geojson_list(multipoly)
multipoly_spdf <- geojson_sp(multipoly)

test_that("ms_simplify works with drop_null_geometries", {
  out_drop <- ms_simplify(multipoly, keep_shapes = FALSE, drop_null_geometries = TRUE)
  expect_equal(out_drop, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-152.823293088065,-51.6391932864114],[-146.114812898716,-56.7281980257939],[-154.774197336172,-60.4935989121959],[-152.823293088065,-51.6391932864114]]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))
  )
  out_nodrop <- ms_simplify(multipoly, keep_shapes = FALSE, drop_null_geometries = FALSE)
  expect_equal(out_nodrop, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-152.823293088065,-51.6391932864114],[-146.114812898716,-56.7281980257939],[-154.774197336172,-60.4935989121959],[-152.823293088065,-51.6391932864114]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":null,\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":null,\"properties\":{\"rmapshaperid\":2}}\n]}", class = c("json", "geo_json"))
  )
})

test_that("ms_simplify.SpatialPolygonsDataFrame works keep_shapes = FALSE and ignores drop_null_geometries", {
  out <- ms_simplify(multipoly_spdf, keep_shapes = FALSE, drop_null_geometries = TRUE)
  expect_equal(length(out@polygons), 1)
  out_nodrop <- ms_simplify(multipoly_spdf, keep_shapes = FALSE, drop_null_geometries = FALSE)
  expect_equal(out, out_nodrop)
})

test_that("ms_simplify works with lines", {
  expected_json <- structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[-145.823797406629,38.9089996693656],[168.682718127966,2.06833674106747]]},\"properties\":{\"rmapshaperid\":0}}\n]}", class = c("json", "geo_json"))


  expect_equal(ms_simplify(line), expected_json)
  expect_equal(ms_simplify(line_list), geojson_list(expected_json), tolerance = 1e-7)
  expect_equal(ms_simplify(line_spdf), geojson_sp(expected_json))
  expect_equal(ms_simplify(line_sp), as(ms_simplify(line_spdf), "SpatialLines"))
})

test_that("ms_simplify works correctly when all geometries are dropped", {
  expect_error(ms_simplify(multipoly_spdf, keep = 0.001), "Cannot convert result to a Spatial\\* object")
  expect_equal(ms_simplify(multipoly, keep = 0.001), structure("{\"type\":\"GeometryCollection\",\"geometries\":[\n\n]}", class = c("json",
                                                                                                                                    "geo_json")))
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
  expect_equal(poly_not_snapped, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[101,3],[103,3],[103,2],[102,2],[101,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[102,1.9],[103,2],[103,1],[101,1],[101,2]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json", "geo_json")))

  poly_snapped <- ms_simplify(poly, keep = 0.8, snap = TRUE, snap_interval = 0.11)
  expect_equal(poly_snapped, structure("{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[101,3],[103,3],[103,2],[102,2],[101,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[102,2],[103,2],[103,1],[101,1],[101,2]]]},\"properties\":{\"rmapshaperid\":1}}\n]}", class = c("json","geo_json")))
})

test_that("ms_simplify works with very small values of 'keep", {
  expect_s3_class(ms_simplify(poly, keep = 0.0001), "geo_json")
})


# SF ----------------------------------------------------------------------

if (has_sf) {
  test_that("ms_simplify works with sf", {
    multipoly_sf <- st_as_sf(multipoly_spdf)
    line_sf <- st_as_sf(line_spdf)
    expect_is(ms_simplify(multipoly_sf), c("sf", "data.frame"))
    expect_is(ms_simplify(line_sf), c("sf", "data.frame"))
  })


  test_that("ms_simplify works with sfc", {
    poly_sfc <- st_as_sfc(poly_sp)
    line_sfc <- st_as_sfc(line_sp)
    expect_is(ms_simplify(poly_sfc), c("sfc_POLYGON", "sfc"))
    expect_is(ms_simplify(line_sfc), c("sfc_LINESTRING", "sfc"))
  })
}
