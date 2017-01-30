context("Col class retention")
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(sf))

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

test_that("Restore column classes works with sf", {
  p_list <- lapply(list(c(3.2,4), c(3,4.6), c(3.8,4.4)), st_point)
  pt_sfc <- st_sfc(p_list)
  pt_sf <- st_sf(x = c("a", "b", "c"), y = 1:3, z = factor(c("X", "Y", "Z")),
                 geometry = pt_sfc, stringsAsFactors = FALSE, crs = 4326)

  orig_classes <- col_classes(pt_sf)

  out_sf <- st_read(geojsonio::geojson_json(pt_sf), quiet = TRUE,
                    stringsAsFactors = FALSE)
  expect_false(isTRUE(all.equal(orig_classes, col_classes(out_sf))))

  restored_sf <- restore_classes(out_sf, orig_classes)
  expect_equal(restored_sf, pt_sf)
})
