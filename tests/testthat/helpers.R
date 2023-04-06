has_sys_mapshaper <- function() {
  nzchar(Sys.which("mapshaper"))
}

skip_on_old_v8 <- function() {
  if (check_v8_major_version() < 6) {
    testthat::skip("Skipping due to old V8 engine")
  }
}

expect_equivalent <- function(object, expected, ...) {
  if (inherits(object, "Spatial") && .hasSlot(object, "proj4string")) {
    comment(object@proj4string) <- NULL
    comment(expected@proj4string) <- NULL
  }
  testthat::expect_equal(object, expected, ignore_attr = TRUE, ...)
}
