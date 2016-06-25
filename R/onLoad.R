ms <- NULL

.onLoad <- function(libname, pkgname){
  ms <<- V8::v8()
  ms$source(system.file("mapshaper/mapshaper-browserify.js", package = pkgname))
}
