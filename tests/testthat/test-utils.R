context("Utilites")
suppressPackageStartupMessages(library(jsonlite))

test_df <- data.frame(char = letters[1:3], dbl = c(1.1, 2.2, 3.3),
                      int = c(1L, 2L, 3L), fct = factor(LETTERS[4:6]),
                      ord = ordered(LETTERS[7:9], levels = rev(LETTERS[7:9])),
                      date = as.Date(c("2016-01-25", "2017-01-27", "1979-03-09")),
                      posix_ct = as.POSIXct(c("2016-01-25 11:25:03",
                                              "2017-01-27 23:24:56",
                                              "1979-03-09 10:25:15")),
                      stringsAsFactors = FALSE)
test_df$posix_lt <- as.POSIXlt(test_df$posix_ct)

test_that("Restore column works", {
  cls <- col_classes(test_df)
  expect_is(cls, "list")
  expect_equal(length(cls), ncol(test_df))

  back_in <- fromJSON(toJSON(test_df))
  expect_equal(unname(sapply(back_in, class)),
               c("character", "numeric", "integer", "character", "character",
                 "character", "character", "character"))
  restored <- restore_classes(df = back_in, classes = cls)
  expect_equal(lapply(test_df, class), lapply(restored, class))
  expect_equal(test_df, restored)
})

test_that("Restore columns works with rmapshaperid column", {
  df <- data.frame(a = "foo", rmapshaperid = 1L, stringsAsFactors = FALSE)
  cls <- col_classes(df)
  expect_equal(names(restore_classes(df, cls)), "a")
  expect_equal(names(restore_classes(df[, 1, drop = FALSE], cls[1])), "a")
  expect_equal(names(restore_classes(df[, 2, drop = FALSE], cls[2])), "rmapshaperid")
})

test_that("dealing with encoding works", {
  pts <- "{\"type\":\"FeatureCollection\",\"features\":[\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-78,-53]},\"properties\":{\"x\":\"Provence-Alpes-Côte d'Azur\"}}]}"
  Encoding(pts) <- "UTF-8"
  out <- GeoJSON_to_sp(pts)
  expect_is(out, "SpatialPointsDataFrame")
  expect_equal(out$x[1], "Provence-Alpes-Côte d'Azur")
})

test_that("geometry column name is preserved", {
  d <- data.frame(a = 1:2)
  d$SHAPE <- c("POINT(0 0)", "POINT(0 1)")
  df <- sf::st_as_sf(d, wkt = "SHAPE")
  out <- ms_filter_fields(df, "a")
  expect_equal(attr(out, "sf_column"), "SHAPE")
})

test_that("NA values dealt with in sf_to_GeoJSON", {
  sf_obj <- sf::st_sf(
    a = c(1.0, NA_real_),
    sf::st_as_sfc(c("POINT(0 0)", "POINT(1 1)"))
  )
  geojson <- sf_to_GeoJSON(sf_obj)
  expect_equivalent(geojson,
                    structure(
                      "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"a\":1},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]}},{\"type\":\"Feature\",\"properties\":{\"a\":null},\"geometry\":{\"type\":\"Point\",\"coordinates\":[1,1]}}]}",
                      class = "json"
                    )
  )
  back_to_sf <- GeoJSON_to_sf(geojson, proj = attr(geojson, "proj"))
  expect_equivalent(sf_obj, back_to_sf)
})

test_that("utilities for checking v8 engine work", {
  expect_is(check_v8_major_version(), "integer")
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
  opts <- options(ms_tempdir = file.path(tempdir(), "path with. spaces"))
  on.exit(options(opts), add = TRUE)
  expect_silent(sys_mapshaper(geojson, poly, command = "--clip"))
})

test_that("ms_de_unit works", {
  skip_if_not_installed("units")
  df <- datasets::iris
  df$Sepal.Length <- units::as_units(df$Sepal.Length, "mm")
  expect_true(inherits(df$Sepal.Length, "units"))
  expect_warning(out <- ms_de_unit(df), "units")
  expect_false(any(vapply(out, inherits, "units", FUN.VALUE = logical(1))))
})