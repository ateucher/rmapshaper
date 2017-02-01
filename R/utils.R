#' Apply a mapshaper command string to a geojson object
#'
#' @param data geojson object
#' @param command valid mapshaper command string
#' @param force_FC should the output be forced to be a FeatureCollection (or
#'  Spatial*DataFrame) even if there are no attributes? Default \code{TRUE}.
#'  FeatureCollections are more compatible with rgdal::readOGR and
#'  geojsonio::geojson_sp. If FALSE and there are no attributes associated with
#'  the geometries, a GeometryCollection (or Spatial object with no dataframe)
#'  will be output.
#'
#' @return geojson
#' @export
apply_mapshaper_commands <- function(data, command, force_FC) {

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

  ms <- ms_make_ctx()

  ## Create a JS object to hold the returned data
  ms$eval("var return_data;")

  ## create a JS callback function
  callback <- "function(Error, data) {
    if (Error) console.error(Error);
    return_data = data;
  }"

  ms$call("mapshaper.applyCommands", command, data, V8::JS(callback))
  ret <- ms$get("return_data")
  class_geo_json(ret)
}

ms_make_ctx <- function() {
  ctx <- V8::v8()
  ctx$source(system.file("mapshaper/mapshaper-browserify.js",
                         package = "rmapshaper"))
  ctx
}

ms_sp <- function(input, call, out_class = class(input)[1]) {

  has_data <- .hasSlot(input, "data")
  if (has_data) {
    classes <- col_classes(input@data)
  }

  geojson <- sp_to_GeoJSON(input)

  ret <- apply_mapshaper_commands(data = geojson, command = call, force_FC = TRUE)

  if (grepl('^\\{"type":"GeometryCollection"', ret)) {
    stop("Cannot convert result to a Spatial* object.
         It is likely too much simplification was applied and all features
         were reduced to null.", call. = FALSE)
  }

  ret <- GeoJSON_to_sp(ret, proj = attr(geojson, "proj4"))

  # remove data slot if input didn't have one (default out_class is the class of the input)
  if (!has_data) {
    ret <- as(ret, out_class)
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

sp_to_GeoJSON <- function(sp){
  proj <- sp::proj4string(sp)
  tmp <- tempfile(fileext = ".geojson")
  suppressMessages(geojsonio::geojson_write(sp, file = tmp))
  js <- class_geo_json(readr::read_file(tmp, locale = readr::locale()))
  structure(js, proj4 = proj)
}

ms_compact <- function(l) Filter(Negate(is.null), l)

add_dummy_id_command <- function() {
  "-each 'rmapshaperid = $.id'"
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
  x@data[x@data == "{ }"] <- NA
  x
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
    classes$rmapshaperid <- list(class = "integer")
    df$rmapshaperid <- as.integer(df$rmapshaperid)
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