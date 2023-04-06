test_df <- data.frame(char = letters[1:3], dbl = c(1.1, 2.2, 3.3),
                      int = c(1L, 2L, 3L), fct = factor(LETTERS[4:6]),
                      ord = ordered(LETTERS[7:9], levels = rev(LETTERS[7:9])),
                      date = as.Date(c("2016-01-25", "2017-01-27", "1979-03-09")),
                      posix_ct = as.POSIXct(c("2016-01-25 11:25:03",
                                              "2017-01-27 23:24:56",
                                              "1979-03-09 10:25:15")),
                      "column 6" = 1:3,
                      stringsAsFactors = FALSE,
                      check.names = FALSE)

test_that("Restore column works", {
  cls <- col_classes(test_df)
  expect_type(cls, "list")
  expect_equal(length(cls), ncol(test_df))

  back_in <- fromJSON(toJSON(test_df))
  expect_equal(unname(sapply(back_in, class)),
               c("character", "numeric", "integer", "character", "character",
                 "character", "character", "integer"))
  restored <- restore_classes(df = back_in, classes = cls)
  expect_equal(lapply(test_df, class), lapply(restored, class))
  expect_equal(names(test_df), names(restored)) # retain special names, https://github.com/ateucher/rmapshaper/issues/91
  expect_equal(test_df, restored)
  test_df$posix_lt <- as.POSIXlt(test_df$posix_ct)
  expect_error(col_classes(test_df), "POSIXlt classes not supported")
})

test_that("Restore columns works with rmapshaperid column", {
  df <- data.frame(a = "foo", rmapshaperid = 1L, stringsAsFactors = FALSE)
  cls <- col_classes(df)
  expect_equal(names(restore_classes(df, cls)), "a")
  expect_equal(names(restore_classes(df[, 1, drop = FALSE], cls[1])), "a")
  expect_equal(names(restore_classes(df[, 2, drop = FALSE], cls[2])), "rmapshaperid")
})

test_that("dealing with encoding works", {
  test_name <- "örtchen"
  test_value <- "Münster"
  Encoding(test_name) <- "UTF-8"
  Encoding(test_value) <- "UTF-8"

  pts <- "{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-78,-53]},\"properties\":{\"örtchen\":\"Münster\"}}]}"
  Encoding(pts) <- "UTF-8"

  out <- GeoJSON_to_sp(pts)
  expect_s4_class(out, "SpatialPointsDataFrame")
  expect_equal(out[1][[1]], test_value)
  expect_equal(names(out), test_name)


  out <- GeoJSON_to_sf(pts)
  expect_s3_class(out, "sf")
  expect_equal(out[1][[1]], test_value)
  expect_equal(names(out)[1], test_name)
})

test_that("geometry column name is preserved", {
  d <- data.frame(a = 1:2)
  d$SHAPE <- c("POINT(0 0)", "POINT(0 1)")
  df <- sf::st_as_sf(d, wkt = "SHAPE")
  out <- ms_filter_fields(df, "a")
  expect_equal(attr(out, "sf_column"), "SHAPE")
})

test_that("NA values dealt with in sf_to_GeoJSON and GeoJSON_to_sf", {
  sf_obj <- sf::st_sf(
    a = c(1.0, NA_real_),
    geometry = sf::st_as_sfc(c("POINT(0 0)", "POINT(1 1)"))
  )
  geojson <- sf_to_GeoJSON(sf_obj)
  expect_snapshot_value(geojson, style = "json2")

  back_to_sf <- GeoJSON_to_sf(geojson, crs = attr(geojson, "crs"))
  expect_equal(sf_obj, back_to_sf)
})

test_that("utilities for checking v8 engine work", {
  expect_type(check_v8_major_version(), "integer")
})


test_that("an sf data frame with no columns works", {
  points <- geojsonsf::geojson_sf("{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[53.7702,-40.4873]}},{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[58.0202,-43.634]}}]}")
  expect_silent(ms_sf(points, "-info"))
  expect_true(grepl("\"type\":\"FeatureCollection\"", sf_to_GeoJSON(points)))
})

test_that("sys_mapshaper works with spaces in path (#107)", {
  skip_if_not(has_sys_mapshaper())
  geojson <- "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"a\":1},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]}},{\"type\":\"Feature\",\"properties\":{\"a\":null},\"geometry\":{\"type\":\"Point\",\"coordinates\":[1,1]}}]}"
  poly <- '{
"type": "Feature",
"properties": {},
"geometry": {
"type": "Polygon",
"coordinates": [
[
[0.5, 1.5],
[1.5, 1.5],
[1.5, 0.5],
[0.5, 0.5],
[0.5, 1.5]
]
]
}
}'
  withr::local_options(ms_tempdir = file.path(tempdir(), "path with. spaces"))
  expect_match(temp_geojson(), "path with. spaces")
  expect_silent(sys_mapshaper(geojson, poly, command = "-clip"))
})

test_that("ms_de_unit works", {
  skip_if_not_installed("units")
  df <- datasets::iris
  df$Sepal.Length <- units::as_units(df$Sepal.Length, "mm")
  expect_true(inherits(df$Sepal.Length, "units"))
  expect_warning(out <- ms_de_unit(df), "units")
  expect_false(any(vapply(out, inherits, "units", FUN.VALUE = logical(1))))
})