#' @importFrom V8 new_context
#'
ms <- NULL

.onLoad <- function(libname, pkgname){
  ms <<- new_context()
  ms$source(system.file("mapshaper/mapshaper.js", package = pkgname))
}
