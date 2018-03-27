has_sys_mapshaper <- function() {
  nzchar(Sys.which("mapshaper"))
}

clean_ws <- function(x) gsub("\\s+", "", x)
