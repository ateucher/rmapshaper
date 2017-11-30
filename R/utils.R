#' Apply a mapshaper command string to a geojson object
#'
#' @param data geojson object or path to geojson file. If a file path, \code{sys}
#' must be true
#' @param command valid mapshaper command string
#' @param force_FC should the output be forced to be a FeatureCollection (or
#'  Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'  the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'  will be output.
#' @param sys Should the system mapshaper command-line utility be used? This involves
#' a round-trip to disk but is much faster on very large objects.
#'
#' @return geojson
#' @export
apply_mapshaper_commands <- function(data, command, force_FC, sys = FALSE) {

  if (file.exists(data) & !sys) {
    stop("'data' points to a file on disk but you did not specify to use
         the system mapshaper. To do so set sys = TRUE")
  }

  ## Add a dummy id to make sure object is a FeatureCollection, otherwise
  ## a GeometryCollection will be returned, which readOGR doesn't usually like.
  ## See discussion here: https://github.com/mbloch/mapshaper/issues/99.
  if (force_FC) {
    add_id <- add_dummy_id_command()
  } else {
    add_id <- NULL
  }

  command <- c(command, add_id)

  command <- paste(ms_compact(command), collapse = " ")

  if (sys) {
    ret <- sys_mapshaper(data = data, command = command)
  } else {
    ms <- ms_make_ctx()

    ## Create a JS object to hold the returned data
    ms$eval("var return_data;")

    ms$call("mapshaper.applyCommands", command, as.character(data), V8::JS(callback()))
    ret <- ms$get("return_data")
    ret <- class_geo_json(ret)
  }
  ret

}

ms_make_ctx <- function() {
  ctx <- V8::v8()
  ctx$source(system.file("mapshaper/mapshaper-browserify.js",
                         package = "rmapshaper"))
  ctx
}

sys_mapshaper <- function(data, command) {
  check_sys_mapshaper()

  # Check if need to read/write the file or if it's been written already
  # by write_sf or writeOGR
  read_write <- !file.exists(data)

  if (read_write) {
    in_data_file <- tempfile(fileext = ".geojson")
    readr::write_file(data, in_data_file)
  } else {
    in_data_file <- data
  }
  on.exit(unlink(in_data_file))

  out_data_file <- tempfile(fileext = ".geojson")
  cmd <- paste("mapshaper", in_data_file, command, "-o", out_data_file)
  suppressMessages(system(cmd))

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

ms_sp <- function(input, call, sys = FALSE) {

  has_data <- .hasSlot(input, "data")
  if (has_data) {
    classes <- col_classes(input@data)
  }

  geojson <- sp_to_GeoJSON(input, file = sys)

  ret <- apply_mapshaper_commands(data = geojson, command = call, force_FC = TRUE, sys = sys)

  if (!sys & grepl('^\\{"type":"GeometryCollection"', ret)) {
    stop("Cannot convert result to a Spatial* object.
         It is likely too much simplification was applied and all features
         were reduced to null.", call. = FALSE)
  }

  ret <- GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))

  # remove data slot if input didn't have one (default out_class is the class of the input)
  if (!has_data) {
    ret <- as(ret, gsub("DataFrame$", "", class(ret)[1]))
  }  else {
    ret@data <- restore_classes(ret@data, classes)
  }

  ret
}

GeoJSON_to_sp <- function(geojson, proj = NULL) {
  sp <- suppressWarnings(
    suppressMessages(
    rgdal::readOGR(geojson, "OGRGeoJSON", verbose = FALSE,
                   disambiguateFIDs = TRUE, p4s = proj,
                   stringsAsFactors = FALSE)
    ))
  curly_brace_na(sp)
}

sp_to_GeoJSON <- function(sp, file = FALSE){
  proj <- sp::proj4string(sp)
  if (file) {
    js <- sf_sp_to_tempfile(sp)
  } else {
    js <- geojsonio::geojson_json(sp)
  }
  structure(js, proj4 = proj)
}

## Utilties for sf
ms_sf <- function(input, call, sys = FALSE) {

  check_sf_pkg()

  has_data <- is(input, "sf")
  if (has_data) {
    classes <- col_classes(input)
  }

  geojson <- sf_to_GeoJSON(input, file = sys)

  ret <- apply_mapshaper_commands(data = geojson, command = call, force_FC = TRUE, sys = sys)

  if (!sys & grepl('^\\{"type":"GeometryCollection"', ret)) {
    stop("Cannot convert result to an sf object.
         It is likely too much simplification was applied and all features
         were reduced to null.", call. = FALSE)
  }

  ret <- GeoJSON_to_sf(ret, proj = attr(geojson, "proj4"))

  ## Only return sfc if that's all that was input
  if (!has_data) {
    ret <- sf::st_geometry(ret)
  } else {
    ret <- restore_classes(ret, classes)
  }

  ret
}

GeoJSON_to_sf <- function(geojson, proj = NULL) {
  sf <- sf::read_sf(unclass(geojson))
  if (!is.null(proj)) {
    suppressWarnings(sf::st_crs(sf) <- proj)
  }
  curly_brace_na(sf)
}

sf_to_GeoJSON <- function(sf, file = FALSE){
  proj <- sf::st_crs(sf)
  if (file) {
    js <- sf_sp_to_tempfile(sf)
  } else {
    js <- suppressMessages(geojsonio::geojson_json(sf, type = 'auto'))
  }
  structure(js, proj4 = proj)
}

sf_sp_to_tempfile <- function(obj) {
  path <- suppressMessages(
    geojsonio::geojson_write(obj, file = tempfile(fileext = ".geojson"))
    )
  normalizePath(path[["path"]], winslash = "/", mustWork = TRUE)
}

check_sf_pkg <- function() {
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Package sf required to operate on sf/sfc classes")
  }
}

check_sys_mapshaper <- function() {
  if (!nzchar(Sys.which("mapshaper"))) {
    stop("The mapshaper node library must be installed and on your path.\n",
         "Install node.js (https://nodejs.org/en/) and then install mapshaper with:\n
         npm install -g mapshaper")
  }

  sys_ms_version <- package_version(system("mapshaper --version 2>&1", intern = TRUE))
  min_ms_version <- package_version("0.4.0") # Update when updating bundled mapshaper.js

  if (sys_ms_version < min_ms_version) {
    stop("You need to upgrade your system mapshaper library.\n",
         "Update it with: 'npm update -g mapshaper")
  }
}

ms_compact <- function(l) Filter(Negate(is.null), l)

add_dummy_id_command <- function() {
  "-each 'rmapshaperid = this.id'"
}

class_geo_json <- function(x) {
  structure(x, class = c("json", "geo_json"))
}

#' @importFrom geojsonlint geojson_validate
check_character_input <- function(x) {
  ## Collapse to character vector of length one if many lines (e.g., if used readLines)
  if (length(x) > 1) {
    x <- paste0(x, collapse = "")
  }
  if (!geojsonlint::geojson_validate(x)) stop("Input is not valid geojson")
  x
}

## Convert empty curly braces that come out of V8 to NA (that is what they go in as)
curly_brace_na <- function(x) {
  UseMethod("curly_brace_na")
}

curly_brace_na.Spatial <- function(x) {
  x@data[x@data == "{ }"] <- NA
  x
}

curly_brace_na.sf <- function(x) {
  sf_col <- which(names(x) == attr(x, "sf_column"))
  x <- as.data.frame(x)
  x[,-sf_col][x[,-sf_col] == "{ }"] <- NA
  sf::st_as_sf(x)
}

col_classes <- function(df) {
  classes <- lapply(df, function(x) {
    out <- list()
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
    } else {
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