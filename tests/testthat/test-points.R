poly_geojson <- structure("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-76.3,-49.68],[-75.53,-51.13],[-74.71,-56.89],[-84.11,-57.09],[-77.9,-50.62],[-84.12,-49.59],[-76.3,-49.68]]]},\"properties\":{\"x\": -78, \"y\": -53}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-68.77,69.82],[-66.26,62.96],[-74.22,60.87],[-74.12,65.22],[-74.55,65.81],[-75.66,67.03],[-68.77,69.82]]]},\"properties\":{\"x\": -71, \"y\": 65}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[136.27,65.8],[137.78,64.03],[140.03,59.56],[139.48,56.48],[133.64,62.44],[129.67,69.6],[136.27,65.8]]]},\"properties\":{\"x\": 135, \"y\": 65}}]}", class = c("geojson", "json"))

poly_spdf <- GeoJSON_to_sp(poly_geojson)
poly_sp <- as(poly_spdf, "SpatialPolygons")


poly_sf <- st_as_sf(poly_spdf)
poly_sfc <- st_geometry(poly_sf)

test_that("ms_points works with defaults", {
  out_json <- ms_points(poly_geojson)
  expect_s3_class(out_json, "geojson")
  expect_snapshot_value(out_json, style = "json2")

  expect_s3_class(ms_points(unclass(poly_geojson)), "geojson")

  expected_sp <- GeoJSON_to_sp(out_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equivalent(ms_points(poly_spdf), expected_sp)
  expect_equivalent(ms_points(poly_sp), as(expected_sp, "SpatialPoints"))

  skip_if_not(has_sys_mapshaper())
  out_sys_json <- ms_points(poly_geojson, sys = TRUE)
  expect_s3_class(out_sys_json, "geojson")
  expect_snapshot_value(out_sys_json, style = "json2")
  expect_s3_class(ms_points(unclass(poly_geojson), sys = TRUE), "geojson")
  expect_s4_class(ms_points(poly_spdf, sys = TRUE), "SpatialPointsDataFrame")
  expect_s4_class(ms_points(poly_sp, sys = TRUE), "SpatialPoints")
})

test_that("ms_points works with defaults with sf", {
  out_sf <- ms_points(poly_sf)
  expect_s3_class(out_sf, "sf")
  expect_equal(as.character(st_geometry_type(out_sf)), rep("POINT", 3))
  expect_named(out_sf, c("x", "y", "geometry"))

  expect_equivalent(ms_points(poly_sfc), st_geometry(out_sf))

  skip_if_not(has_sys_mapshaper())
  out_sys_sf <- ms_points(poly_sf, sys = TRUE)
  expect_s3_class(out_sys_sf, "sf")
  expect_equal(out_sys_sf, out_sf)
  expect_s3_class(ms_points(poly_sfc, sys = TRUE), "sfc")
})

test_that("ms_points works with location=centroid", {
  out_json <- ms_points(poly_geojson, location = "centroid")
  expect_s3_class(out_json, "geojson")
  expect_snapshot_value(out_json, "json2")

  expected_sp <- GeoJSON_to_sp(out_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equal(out_json, ms_points(poly_geojson))
  expect_equivalent(ms_points(poly_spdf, location = "centroid"), expected_sp)

  expected_sf <- st_read(out_json, quiet = TRUE, stringsAsFactors = FALSE)[1:2]
  expect_equivalent(ms_points(poly_sf, location = "centroid"), expected_sf)
  expect_equivalent(ms_points(poly_sfc, location = "centroid"), st_geometry(expected_sf))
})

test_that("ms_points works with location=inner", {
  out_json <- ms_points(poly_geojson, location = "inner")
  expect_s3_class(out_json, "geojson")
  expect_snapshot_value(out_json, style = "json2")

  expected_sp <- GeoJSON_to_sp(out_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equivalent(ms_points(poly_spdf, location = "inner"), expected_sp)

  expected_sf <- st_read(out_json, quiet = TRUE, stringsAsFactors = FALSE)[1:2]
  expect_equal(ms_points(poly_sf, location = "inner"), expected_sf)
  expect_equal(ms_points(poly_sfc, location = "inner"), st_geometry(expected_sf))

  skip_if_not(has_sys_mapshaper())
  out_sys_sf <- ms_points(poly_sf, location = "inner", sys = TRUE)
  expect_s3_class(out_sys_sf, "sf")
  expect_equal(out_sys_sf, expected_sf)
  expect_s3_class(ms_points(poly_sfc, location = "inner",  sys = TRUE), "sfc")
})

test_that("ms_points works with x and y", {
  out_json <- ms_points(poly_geojson, x = "x", y = "y")
  expect_s3_class(out_json, "geojson")
  expect_snapshot_value(out_json, "json2")

  expected_sp <- GeoJSON_to_sp(out_json)
  expected_sp <- expected_sp[, setdiff(names(expected_sp), "rmapshaperid")]

  expect_equivalent(ms_points(poly_spdf, x = "x", y = "y"), expected_sp)

  out_sf <- ms_points(poly_sf, x = "x", y = "y")
  expect_equivalent(out_sf,
               st_read(out_json, quiet = TRUE, stringsAsFactors = FALSE)[1:2])

  skip_if_not(has_sys_mapshaper())
  out_sys_sf <- ms_points(poly_sf, x = "x", y = "y", sys = TRUE)
  expect_s3_class(out_sys_sf, "sf")
  expect_equal(out_sys_sf, out_sf)
})

test_that("ms_points fails correctly", {
  expect_error(ms_points(poly_geojson, location = "foo"), "location must be 'centroid' or 'inner'")
  expect_error(ms_points(poly_geojson, location = "inner", x = "x", y = "y"),
               "You have specified both a location and x/y for point placement")
  expect_error(ms_points(poly_geojson, location = "inner", x = "x"),
               "You have specified both a location and x/y for point placement")
  expect_error(ms_points(poly_geojson, location = "inner", y = "y"),
               "You have specified both a location and x/y for point placement")
  expect_error(ms_points(poly_geojson, x = "x"), "Only one of x/y pair found")
  expect_error(ms_points(poly_geojson, y = "y"), "Only one of x/y pair found")
  expect_error(ms_points(poly_geojson, force_FC = "true"),
               "force_FC must be TRUE or FALSE")

  # sfc and SpatialPolygons (i.e., no attributes)
  expect_error(ms_points(poly_sfc, x = "x", y = "y"),
               "Objects of class sfc have no columns")

  expect_error(ms_points(poly_sp, x = "x", y = "y"),
               "SpatialPolygons objects do not have columns")
})
