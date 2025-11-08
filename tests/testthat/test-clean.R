test_that("ms_clean works with geojson/character input", {
  # Simple polygon with no issues
  simple_poly <- structure('{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "Polygon",
      "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]]
    }
  }', class = c("geojson", "json"))
  
  result <- ms_clean(simple_poly)
  expect_s3_class(result, "geojson")
  expect_true(jsonify::validate_json(result))
  
  # Test character input
  expect_equal(ms_clean(as.character(simple_poly)), result)
})

test_that("ms_clean works with overlapping polygons", {
  overlapping_poly <- structure('{
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "properties": {"id": 1},
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[0, 0], [2, 0], [2, 2], [0, 2], [0, 0]]]
        }
      },
      {
        "type": "Feature", 
        "properties": {"id": 2},
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[1, 1], [3, 1], [3, 3], [1, 3], [1, 1]]]
        }
      }
    ]
  }', class = c("geojson", "json"))
  
  result <- ms_clean(overlapping_poly)
  expect_s3_class(result, "geojson")
  expect_true(jsonify::validate_json(result))
  
  # Test with different overlap rules
  result_min_area <- ms_clean(overlapping_poly, overlap_rule = "min-area")
  expect_s3_class(result_min_area, "geojson")
  expect_true(jsonify::validate_json(result_min_area))
  
  # Test allow_overlaps
  result_allow <- ms_clean(overlapping_poly, allow_overlaps = TRUE)
  expect_s3_class(result_allow, "geojson")
  expect_true(jsonify::validate_json(result_allow))
})

test_that("ms_clean works with sf objects", {
  skip_if_not_installed("sf")
  
  # Create sf object with overlapping polygons
  library(sf)
  
  poly1 <- st_polygon(list(rbind(c(0,0), c(2,0), c(2,2), c(0,2), c(0,0))))
  poly2 <- st_polygon(list(rbind(c(1,1), c(3,1), c(3,3), c(1,3), c(1,1))))
  
  sf_obj <- st_sf(
    id = c(1, 2),
    geometry = st_sfc(poly1, poly2)
  )
  
  result <- ms_clean(sf_obj)
  expect_s3_class(result, "sf")
  expect_true(all(st_is_valid(result)))
  
  # Test with parameters
  result_params <- ms_clean(sf_obj, sliver_control = 0.5, rewind = TRUE)
  expect_s3_class(result_params, "sf")
  expect_true(all(st_is_valid(result_params)))
})

test_that("ms_clean works with sfc objects", {
  skip_if_not_installed("sf")
  
  library(sf)
  
  poly1 <- st_polygon(list(rbind(c(0,0), c(1,0), c(1,1), c(0,1), c(0,0))))
  sfc_obj <- st_sfc(poly1)
  
  result <- ms_clean(sfc_obj)
  expect_s3_class(result, "sfc")
  expect_true(all(st_is_valid(result)))
})

test_that("ms_clean works with Spatial objects", {
  skip_if_not_installed("sp")
  skip_if_not_installed("rgeos")
  
  library(sp)
  
  # Create simple SpatialPolygons
  coords <- rbind(c(0,0), c(1,0), c(1,1), c(0,1), c(0,0))
  poly <- Polygon(coords)
  polys <- Polygons(list(poly), ID = "1")
  sp_obj <- SpatialPolygons(list(polys))
  
  result <- ms_clean(sp_obj)
  expect_s4_class(result, "SpatialPolygons")
  
  # Test with SpatialPolygonsDataFrame
  spdf_obj <- SpatialPolygonsDataFrame(sp_obj, data.frame(id = 1))
  result_df <- ms_clean(spdf_obj)
  expect_s4_class(result_df, "SpatialPolygonsDataFrame")
})

test_that("ms_clean works with line features", {
  # Self-intersecting line
  line_geojson <- structure('{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "LineString",
      "coordinates": [[0, 0], [2, 0], [1, 1], [1, -1]]
    }
  }', class = c("geojson", "json"))
  
  result <- ms_clean(line_geojson)
  expect_s3_class(result, "geojson")
  expect_true(jsonify::validate_json(result))
})

test_that("ms_clean works with point features", {
  # Points with duplicates
  points_geojson <- structure('{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "MultiPoint",
      "coordinates": [[0, 0], [0, 0], [1, 1]]
    }
  }', class = c("geojson", "json"))
  
  result <- ms_clean(points_geojson)
  expect_s3_class(result, "geojson")
  expect_true(jsonify::validate_json(result))
})

test_that("ms_clean parameter validation works", {
  simple_poly <- structure('{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "Polygon",
      "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]]
    }
  }', class = c("geojson", "json"))
  
  # Test invalid gap_fill_area
  expect_error(ms_clean(simple_poly, gap_fill_area = -1))
  expect_error(ms_clean(simple_poly, gap_fill_area = "invalid"))
  
  # Test invalid sliver_control
  expect_error(ms_clean(simple_poly, sliver_control = -1))
  expect_error(ms_clean(simple_poly, sliver_control = 2))
  
  # Test invalid overlap_rule
  expect_error(ms_clean(simple_poly, overlap_rule = "invalid"))
  
  # Test invalid snap_interval
  expect_error(ms_clean(simple_poly, snap_interval = -1))
  expect_error(ms_clean(simple_poly, snap_interval = "invalid"))
})

test_that("ms_clean works with various parameter combinations", {
  simple_poly <- structure('{
    "type": "Feature",
    "properties": {},
    "geometry": {
      "type": "Polygon",
      "coordinates": [[[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]]
    }
  }', class = c("geojson", "json"))
  
  # Test with gap_fill_area
  result1 <- ms_clean(simple_poly, gap_fill_area = 100)
  expect_s3_class(result1, "geojson")
  
  # Test with sliver_control
  result2 <- ms_clean(simple_poly, sliver_control = 0.5)
  expect_s3_class(result2, "geojson")
  
  # Test with snap_interval
  result3 <- ms_clean(simple_poly, snap_interval = 0.01)
  expect_s3_class(result3, "geojson")
  
  # Test with rewind and allow_empty
  result4 <- ms_clean(simple_poly, rewind = TRUE, allow_empty = TRUE)
  expect_s3_class(result4, "geojson")
  
  # Test with multiple parameters
  result5 <- ms_clean(simple_poly, 
                      gap_fill_area = 50, 
                      sliver_control = 0.8, 
                      overlap_rule = "min-id",
                      snap_interval = 0.001)
  expect_s3_class(result5, "geojson")
})
