has_sys_mapshaper <- function() {
  nzchar(Sys.which("mapshaper"))
}

clean_ws <- function(x) gsub("\\s+", "", x)

skip_on_old_v8 <- function() {
  if (check_v8_major_version() < 6) {
    testthat::skip("Skipping due to old V8 engine")
  }
}

