ms <- NULL

.onLoad <- function(libname, pkgname){
  ms <<- V8::v8()
  ms$source(system.file("js/mapshaper-browserify.min.js", package = pkgname))
}
