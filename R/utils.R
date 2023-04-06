#' Apply a mapshaper command string to a geojson object
#'
#' @param data character containing geojson or path to geojson file.
#' If a file path, \code{sys} must be true.
#' @param command valid mapshaper command string
#' @param force_FC should the output be forced to be a FeatureCollection (or sf object or
#'   Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}. If FALSE and
#'   there are no attributes associated with the geometries, a
#'   GeometryCollection (or Spatial object with no dataframe, or sfc) will be output.
#' @param sys Should the system mapshaper be used instead of the bundled mapshaper? Gives
#'   better performance on large files. Requires the mapshaper node package to be installed
#'   and on the PATH.
#' @param sys_mem How much memory (in GB) should be allocated if using the system
#'   mapshaper (`sys = TRUE`)? Default 8. Ignored if `sys = FALSE`.
#'   This can also be set globally with the option `"mapshaper.sys_mem"`
#' @param quiet If `sys = TRUE`, should the mapshaper messages be silenced? Default `FALSE`.
#'   This can also be set globally with the option `"mapshaper.sys_quiet"`
#'
#' @return geojson
#' @export
#' @examples
#'
#' nc <- sf::read_sf(system.file("gpkg/nc.gpkg", package = "sf"))
#' rmapshaper::apply_mapshaper_commands(geojsonsf::sf_geojson(nc), "-clean")
#'
apply_mapshaper_commands <- function(data, command, force_FC = TRUE, sys = FALSE,
                                     sys_mem = getOption("mapshaper.sys_mem", default = 8),
                                     quiet = getOption("mapshaper.sys_quiet", default = FALSE)) {
  if (!is.logical(force_FC)) stop("force_FC must be TRUE or FALSE", call. = FALSE)
  if (!is.logical(sys)) stop("sys must be TRUE or FALSE", call. = FALSE)
  if (!is.numeric(sys_mem)) stop("sys_mem must be numeric", call. = FALSE)

  data <- as.character(data)

  if (!is.numeric(sys_mem) )

  if (nchar(data) < 1000L && file.exists(data) && !sys) {
    stop("'data' points to a file on disk but you did not specify to use
         the system mapshaper. To do so set sys = TRUE")
  }

  ## Add a dummy id to make sure object is a FeatureCollection, otherwise
  ## a GeometryCollection will be returned, which readOGR doesn't usually like.
  ## See discussion here: https://github.com/mbloch/mapshaper/issues/99.
  if (force_FC) {
    add_id <- add_dummy_id_command(sys = sys)
  } else {
    add_id <- NULL
  }

  command <- c(command, add_id)

  command <- paste(ms_compact(command), collapse = " ")

  if (sys) {
    ret <- sys_mapshaper(data = data, command = command, sys_mem = sys_mem, quiet = quiet)
  } else {
    ms <- ms_make_ctx()

    ## Create a JS object to hold the returned data
    ms$eval("var return_data;")

    ms$call("mapshaper.applyCommands", command, data,
            V8::JS(callback()))

    # TODO: New syntax for applyCommands:
    # Useful for clip and erase so can define two inputs
    # cmd <- paste("-i input.geojson", command, "-o output.geojson")
    #
    # ms$call("mapshaper.applyCommands", cmd, V8::JS("{'input.geojson': input}"),
    #         V8::JS("function(err, output) {
    # 	return_data = output['output.geojson'];
    # }"))
    ret <- ms$get("return_data")
    ret <- class_geo_json(ret)
  }
  ret

}

ms_make_ctx <- function() {
  ctx <- V8::v8()
  ctx$source(system.file("mapshaper/mapshaper-browserify.min.js",
                         package = "rmapshaper"))
  ctx
}

sys_mapshaper <- function(data, data2 = NULL, command, force_FC = FALSE, # default FALSE as in most cases it is added in apply_mapshaper_commands
                          sys_mem = getOption("mapshaper.sys_mem", default = 8),
                          quiet = getOption("mapshaper.sys_quiet", default = FALSE)) {
  # Get full path to sys mapshaper, use mapshaper-xl
  ms_path <- paste0(check_sys_mapshaper("mapshaper-xl", verbose = FALSE))

  # Check if need to read/write the file or if it's been written already
  # by write_sf or writeOGR
  read_write <- !file.exists(data)

  in_data_file <- data
  in_data_file2 <- data2

  if (read_write) {
    in_data_file <- temp_geojson()
    readr::write_file(data, in_data_file)
    on.exit(unlink(in_data_file))

    if (!is.null(data2)) {
      in_data_file2 <- temp_geojson()
      readr::write_file(data2, in_data_file2)
      on.exit(unlink(in_data_file2), add = TRUE)
    }
  }

  out_data_file <- temp_geojson()

  each <- if (force_FC) {
    add_dummy_id_command(sys = TRUE)
  } else {
    NULL
  }

  cmd_args <- c(
    sys_mem,
    shQuote(in_data_file),
    command,
    shQuote(in_data_file2), # will be NULL if no data2/in_data_file2
    each, # will be NULL if force_FC is FALSE
    "-o", shQuote(out_data_file),
    if (quiet) "-quiet"
  )

  system2(ms_path, cmd_args)

  if (read_write) {
    on.exit(unlink(out_data_file), add = TRUE)
    # Read the geojson object and return it
    ret <- class_geo_json(readr::read_file(out_data_file))
  } else {
    # Return the path to the file
    ret <- out_data_file
  }

  ret
}

ms_get_raw <- function(x) {
  rawToChar(as.raw(x[["data"]]))
}

## create a JS callback function
callback <- function() {
  "function(Error, data) {
if (Error) console.error('Error in V8 context: ' + Error.stack);
return_data = data;
}"
}

ms_sp <- function(input, call, sys = FALSE,
                  sys_mem = getOption("mapshaper.sys_mem", default = 8),
                  quiet = getOption("mapshaper.sys_quiet", default = FALSE)) {

  has_data <- .hasSlot(input, "data")
  if (has_data) {
    classes <- col_classes(input@data)
  }

  geojson <- sp_to_GeoJSON(input, file = sys)

  ret <- apply_mapshaper_commands(data = geojson, command = call, force_FC = TRUE, sys = sys, sys_mem = sys_mem, quiet = quiet)

  if (!sys & grepl('^\\{"type":"GeometryCollection"', ret)) {
    stop("Cannot convert result to a Spatial* object.
         It is likely too much simplification was applied and all features
         were reduced to null.", call. = FALSE)
  }

  ret <- GeoJSON_to_sp(ret, crs = attr(geojson, "crs"))

  # remove data slot if input didn't have one (default out_class is the class of the input)
  if (!has_data) {
    ret <- as(ret, gsub("DataFrame$", "", class(ret)[1]))
  }  else {
    ret@data <- restore_classes(ret@data, classes)
  }

  ret
}

GeoJSON_to_sp <- function(geojson, crs = NULL) {
  x_sf <- GeoJSON_to_sf(geojson, crs)
  as(x_sf, "Spatial")
}

sp_to_GeoJSON <- function(sp, file = FALSE){

  crs <- methods::slot(sp, "proj4string")

  if (file) {
    js <- sp_to_tempfile(sp)
  } else {
    js_tmp <- sp_to_tempfile(sp)
    js <- readr::read_file(js_tmp, locale = readr::locale())
    on.exit(unlink(js_tmp))
  }
  structure(js, crs = crs)
}

## Utilties for sf
ms_sf <- function(input, call, sys = FALSE,
                  sys_mem = getOption("mapshaper.sys_mem", default = 8),
                  quiet = getOption("mapshaper.sys_quiet", default = FALSE)) {

  has_data <- is(input, "sf")
  if (has_data) {
    classes <- col_classes(input)
    geom_name <- attr(input, "sf_column")
    input <- ms_de_unit(input)
  } else {
    input <- unname(input)
  }

  geojson <- sf_to_GeoJSON(input, file = sys)

  ret <- apply_mapshaper_commands(data = geojson, command = call, force_FC = TRUE, sys = sys, sys_mem = sys_mem, quiet = quiet)

  if (!sys & grepl('^\\{"type":"GeometryCollection"', ret)) {
    stop("Cannot convert result to an sf object.
         It is likely too much simplification was applied and all features
         were reduced to null.", call. = FALSE)
  }

  ret <- GeoJSON_to_sf(ret, crs = attr(geojson, "crs"))

  ## Only return sfc if that's all that was input
  if (!has_data) {
    ret <- sf::st_geometry(ret)
  } else {
    ret <- restore_classes(ret, classes)
    names(ret)[names(ret) == attr(ret, "sf_column")] <- geom_name
    sf::st_geometry(ret) <- geom_name
  }
  ##maintain tbl_df
  if (all(class(input) == c("sf", "tbl_df", "tbl", "data.frame"))) {
    class(ret) <- c("sf", "tbl_df", "tbl", "data.frame")
  }
  ret
}

GeoJSON_to_sf <- function(geojson, crs = NULL) {
  sf <- geojsonsf::geojson_sf(geojson)
  if (!is.null(crs)) {
    suppressWarnings(sf::st_crs(sf) <- crs)
  }
  curly_brace_na(sf)
}

sf_to_GeoJSON <- function(sf, file = FALSE) {
  crs <- sf::st_crs(sf)

    js <- if (inherits(sf, "sf")) {
      geojsonsf::sf_geojson(sf, simplify = FALSE)
    } else {
      json <- geojsonsf::sfc_geojson(sf)
      paste0("{\"type\":\"GeometryCollection\",\"geometries\":[",
             paste(json, collapse = ","),
             "]}")
    }

    if (file) {
      path <- tempfile(fileext = ".geojson")
      writeLines(js, con = path)
      js <- path
    }
  structure(js, crs = crs)
}


sp_to_tempfile <- function(obj) {
  obj <- sf::st_as_sf(sp_to_spdf(obj))
  path <- tempfile(fileext = ".geojson")
  sf::st_write(obj, path, driver = "GeoJSON", quiet = TRUE, delete_dsn = TRUE)
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

sp_to_spdf <- function(obj) {
  non_df_classes <- c("SpatialLines", "SpatialPolygons", "SpatialPoints")
  cls <- inherits(obj, non_df_classes, which = TRUE)
  if (!any(cls)) {
    return(obj)
  }
    as(obj, paste0(non_df_classes[as.logical(cls)], "DataFrame"))
}

#' Check the system mapshaper
#'
#' @param command either "mapshaper-xl" (default) or "mapshaper"
#' @param verbose Print a message stating mapshaper's current version? Default `TRUE`
#'
#' @return character path to mapshaper executable if appropriate version is installed, otherwise throws an error
#' @export
check_sys_mapshaper <- function(command = "mapshaper-xl", verbose = TRUE) {
  if (!command %in% c("mapshaper-xl", "mapshaper")) {
    stop("command must be one of 'mapshaper-xl' or 'mapshaper'", call. = FALSE)
  }

  ms_path <- sys_ms_path(command)

  sys_ms_version <- package_version(sys_ms_version())
  min_ms_version <- package_version(bundled_ms_version()) # Update when updating bundled mapshaper.js

  if (sys_ms_version < min_ms_version) {
    stop("You need to upgrade your system mapshaper library.\n",
         "Update it with: 'npm update -g mapshaper")
  }
  if (verbose) {
    message("mapshaper version ", sys_ms_version, " is installed and on your PATH")
  }
    ms_path
}

sys_ms_path <- function(command) {
  err_msg <- paste0("The mapshaper node library must be installed and on your PATH.\n",
                    "Install node.js (https://nodejs.org/en/) and then install mapshaper with:\n",
                    "    npm install -g mapshaper")

  ms_path <- Sys.which(command)

  if (!nzchar(ms_path)) {
    # try to find it:
    if (nzchar(Sys.which("npm"))) {
      npm_prefix <- system2("npm",  "get prefix", stdout = TRUE)
      ms_path <- file.path(npm_prefix, "bin", command)
      if (!file.exists(ms_path)) stop(err_msg, call. = FALSE)
    } else {
      stop(err_msg, call. = FALSE)
    }
  }
  ms_path
}

sys_ms_version <- function() {
  system2(sys_ms_path("mapshaper"), "--version", stdout = TRUE)
}

bundled_ms_version <- function() {
  # ms <- ms_make_ctx()
  # ms$get("mapshaper.internal.VERSION")
  "0.6.25"
}

ms_compact <- function(l) Filter(Negate(is.null), l)

add_dummy_id_command <- function(sys) {
  if (sys) {
    cmd <- shQuote("rmapshaperid=this.id")
  } else {
    cmd <- "'rmapshaperid=this.id'"
  }
  paste("-each", cmd)
}

class_geo_json <- function(x) {
  if (is.null(x)) {
    warning("The command returned an empty response. Please check your inputs", call. = FALSE)
    x <- list()
  }
  if (is.raw(x)) {
    x <- rawToChar(x)
  }
  structure(x, class = c("geojson", "json"))
}

check_character_input <- function(x) {
  ## Collapse to character vector of length one if many lines (e.g., if used readLines)
  if (length(x) > 1) {
    x <- paste0(x, collapse = "")
  }
  if (!jsonify::validate_json(x)) stop("Input is not valid geojson")
  x
}

## Convert empty curly braces that come out of V8 to NA (that is what they go in as)
curly_brace_na <- function(x) {
  UseMethod("curly_brace_na")
}

curly_brace_na.data.frame <- function(x) {
  chr_or_factor <- vapply(x, inherits, c("character", "factor"), FUN.VALUE = logical(1))
  if (any(chr_or_factor)) {
    x[, chr_or_factor][x[, chr_or_factor] == "{ }"] <- NA
  }
  x
}

curly_brace_na.Spatial <- function(x) {
  x@data <- curly_brace_na(x@data)
  x
}

# This method basically just removes the sf class and then
# restores it after the data.frame method does its work, because
# the sf column is 'sticky' with `[`.sf methods, so would be
# included in the { } substitution if the sf class was kept
curly_brace_na.sf <- function(x) {
  sf_col <- attr(x, "sf_column")
  class(x) <- setdiff(class(x), "sf")
  x <- curly_brace_na(x)
  sf::st_as_sf(x, sf_column_name = sf_col)
}

col_classes <- function(df) {
  classes <- lapply(df, function(x) {
    out <- list()
    if (inherits(x, "POSIXlt")) {
      stop("POSIXlt classes not supported. Please convert to POSIXct", call. = FALSE)
    }
    out$class <- class(x)
    if (is.factor(x)) {
      out$levels <- levels(x)
      if (is.ordered(x)) {
        out$ordered <- TRUE
      } else {
        out$ordered <- FALSE
      }
    }
    out
  })
  classes
}

restore_classes <- function(df, classes) {

  if ("rmapshaperid" %in% names(df)) {
    nms <- ifelse(is(df, "sf") || is(df, "sfc"),
                  setdiff(names(df), attr(df, "sf_column")),
                  names(df))
    if (length(nms) == 1 && nms == "rmapshaperid") {
      classes$rmapshaperid <- list(class = "integer")
      df$rmapshaperid <- as.integer(df$rmapshaperid)
    } else {
      df <- df[, setdiff(names(df), "rmapshaperid"), drop = FALSE]
    }
  }

  in_classes <- lapply(df, class)

  keep_in_both <- intersect(names(in_classes), names(classes))
  in_classes <- in_classes[keep_in_both]

  class_matches <- vapply(names(in_classes), function(n) {
    if ("sfc" %in% classes[[n]]$class) return(TRUE)
    isTRUE(all.equal(classes[[n]]$class, in_classes[[n]]))
  }, FUN.VALUE = logical(1))

  mismatches <- which(!class_matches)
  if (length(mismatches) == 0) return(df)

  for (n in names(mismatches)) {
    cls <- classes[[n]]$class
    if ("factor" %in% cls) {
      df[[n]] <- factor(df[[n]], levels = classes[[n]]$levels,
                           ordered = classes[[n]]$ordered)
    } else if (!"units" %in% cls) { # Skip units columns... TODO: Fix units parsing on return
      as_fun <- paste0("as.", cls[1])
      tryCatch({
        df[[n]] <- eval(call(as_fun, df[[n]]))
      }, error = function(e) {
        warning("Could not convert column ", names(df)[n], " to class ",
                cls, ". Returning as ", paste(in_classes[[n]], collapse = ", "))
      }
      )
    }
  }
  df
}

stop_for_old_v8 <- function() {
  if (check_v8_major_version() < 6L) {
  # nocov start
    stop(
      "Warning: v8 Engine is version ", V8::engine_info()[["version"]],
      " but version >=6 is required for this function. See",
      " https://github.com/jeroen/V8 for help installing a modern version",
      " of v8 on your operating system.")
  }
  # nocov end
}

check_v8_major_version <- function() {
  engine_version <- V8::engine_info()[["version"]]
  major_version <- as.integer(strsplit(engine_version, "\\.")[[1]][1])
  major_version
}

temp_geojson <- function() {
  # This option is really just to allow testing strange paths like #107
  tmpdir <- getOption("ms_tempdir", default = tempdir())
  dir.create(tmpdir, showWarnings = FALSE)
  normalizePath(tempfile(
    tmpdir = tmpdir,
    fileext = ".geojson"
  ), mustWork = FALSE)
}
