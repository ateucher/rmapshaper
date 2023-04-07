test_that("apply_mapshaper_commands doesn't delete local file", {
  skip_if_not(has_sys_mapshaper())
  geojson <- basic_poly()
  testfile <- "test.geojson"
  withr::local_file(testfile)
  writeLines(geojson, testfile)
  apply_mapshaper_commands(testfile, "--dissolve", force_FC = FALSE, sys = TRUE)
  expect_true(file.exists(testfile))
})

