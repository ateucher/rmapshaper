.onAttach <- function(libname, pkgname){
  # nocov start
  if (check_v8_major_version() < 6L) {
    packageStartupMessage(
      "Warning: v8 Engine is version ", V8::engine_info()[["version"]],
      " but version >=6 is required for full functionality. Some rmapshaper",
      " functions, notably ms_clip() and ms_erase(), may not work. See",
      " https://github.com/jeroen/V8 for help installing a modern version",
      " of v8 on your operating system.")
  }
  # nocov end
}
