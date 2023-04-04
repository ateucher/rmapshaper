has_sys_mapshaper <- function() {
  nzchar(Sys.which("mapshaper"))
}

clean_ws <- function(x) gsub("\\s+", "", x)

skip_on_old_v8 <- function() {
  if (check_v8_major_version() < 6) {
    testthat::skip("Skipping due to old V8 engine")
  }
}

expect_equivalent_json <- function(object, expected, ...) {
  testthat::expect_equivalent(
    unclass(clean_ws(object)),
    unclass(clean_ws(expected)),
    ...
  )
}

expect_equivalent_sfp <- function(object, expected, ...) {
  object <- object[, sort(names(object)), drop = FALSE]
  expected <- expected[, sort(names(expected)), drop = FALSE]

  testthat::expect_equivalent(object, expected, ...)
}
