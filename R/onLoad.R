#' @importFrom V8 new_context
#'
ms <- NULL

.onLoad <- function(libname, pkgname){
  ms <<- V8::new_context()
  ms$source(system.file("mapshaper/mapshaper-browserify.js", package = pkgname))
}
