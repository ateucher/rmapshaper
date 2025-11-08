.onAttach <- function(libname, pkgname) {
  # nocov start
  startup_v8_version_check()
  # nocov end
}

startup_v8_version_check <- function() {
  if (v8_version() < package_version("8.1.307.30")) {
    packageStartupMessage(
      "Warning: v8 Engine is version ",
      v8_version(),
      " but version >= 8.1.307.30 is required for full functionality. See",
      " https://github.com/jeroen/V8 for help installing a modern version",
      " of v8 on your operating system."
    )
  }
}
