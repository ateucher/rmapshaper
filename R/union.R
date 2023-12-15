#' Create a composite polygon layer from two target polygon layers
#'
#' Create a composite layer (a polygon mosaic without overlaps) from two target polygon layers.
#' Data values are copied from source features to output features.
#' Same-named fields in source layers are renamed in the output layer.
#' For example, two source-layer fields named "id" will be renamed to "id_1"
#' and "id_2".
#'
#' @param target the target polygon layer to which the second polygon is added. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{SpatialPolygons};
#'  \item \code{sf} or \code{sfc} polygons object
#'  }
#' @param union the union polygon layer. One of:
#' \itemize{
#'  \item \code{geo_json} or \code{character} polygons;
#'  \item \code{SpatialPolygons*};
#'  \item \code{sf} or \code{sfc} polygons object
#' }
#' @inheritDotParams apply_mapshaper_commands force_FC sys sys_mem quiet gj2008
#'
#' @return composite polygon layer in the same class as the input target
#'
#' @examples
#'
#' if (rmapshaper:::v8_version() >= 6) {
#'   library(geojsonsf, quietly = TRUE)
#'   library(sf)
#'
#'   poly <- structure("{\"type\":\"FeatureCollection\",
#'     \"features\":[{\"type\":\"Feature\",\"properties\":{},
#'     \"geometry\":{\"type\":\"Polygon\",\"coordinates\":
#'     [[[52.8658,-44.7219],[53.7702,-40.4873],[55.3204,-37.5579],
#'     [56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],
#'     [58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],
#'     [55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],
#'     [52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],
#'     [52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],
#'     [50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],
#'     [52.8658,-44.7219]]]}}]}", class = c("geojson", "json"))
#'   poly <- geojson_sf(poly)
#'   plot(poly)
#'
#'   union_poly <- structure('{
#'   "type": "Feature",
#'   "properties": {},
#'   "geometry": {
#'   "type": "Polygon",
#'   "coordinates": [
#'   [
#'   [51, -40],
#'   [55, -40],
#'   [55, -45],
#'   [51, -45],
#'   [51, -40]
#'   ]
#'   ]
#'   }
#'   }', class = c("geojson", "json"))
#'   union_poly <- geojson_sf(union_poly)
#'   plot(union_poly)
#'
#'   out <- ms_union(poly, union_poly)
#'   plot(out)
#' }
#'
#' @export
ms_union <-
  function(target, union, ...) {
  stop_for_old_v8()
  UseMethod("ms_union")
}

#' @export
ms_union.sf <-
  function(target, union, ...) {
  union_sf(target = target, overlay_layer = union, ...)
}

#' @export
ms_union.character <-
  function(target, union, ...) {
    union_json(target = target, overlay_layer = union, ...)
  }

#' @export
ms_union.json <-
  function(target, union, ...) {
    union_json(target = target, overlay_layer = union, ...)
  }

#' @export
ms_union.SpatialPolygons <-
  function(target, union, ...) {
  union_sp(target = target, overlay_layer = union, ...)
}

#' @export
ms_union.sfc <-
  function(target, union, ...) {
  union_sf(target = target, overlay_layer = union, ...)
}

union_json <-
  function(
    target,
    overlay_layer,
    force_FC = TRUE,
    sys = FALSE,
    sys_mem = getOption("mapshaper.sys_mem", default = 8),
    quiet = getOption("mapshaper.sys_quiet", default = FALSE),
    gj2008 = FALSE
  ) {

    if (!is.null(overlay_layer)) {
      overlay_layer <-
        check_character_input(overlay_layer)
    }

    mapshaper_union(
      target_layer = target,
      overlay_layer = overlay_layer,
      force_FC = force_FC,
      sys = sys,
      sys_mem = sys_mem,
      quiet = quiet,
      gj2008 = gj2008
    )

  }

union_sf <-
  function(
    target,
    overlay_layer,
    force_FC = TRUE,
    sys = FALSE,
    sys_mem = getOption("mapshaper.sys_mem", default = 8),
    quiet = getOption("mapshaper.sys_quiet", default = FALSE),
    gj2008 = FALSE
  ) {

    has_data <- is(target, "sf")
    if (has_data) {
      classes <- col_classes(target)
    }

    target_proj <- sf::st_crs(target)

    if (!(inherits(overlay_layer, c("sf", "sfc"))) ||
        !all(sf::st_is(overlay_layer, c("POLYGON", "MULTIPOLYGON")))) {
      stop("Target and Union must be an sf or sfc object with POLYGON or MULTIPLOYGON geometry")
    }
    if (target_proj != sf::st_crs(overlay_layer)) {
      stop("target and union do not have identical CRS.", call. = FALSE)
    }
    overlay_geojson <- sf_to_GeoJSON(overlay_layer, file = sys)

    target_geojson <- sf_to_GeoJSON(target, file = sys)

    result <- mapshaper_union(
      target_layer = target_geojson,
      overlay_layer = overlay_geojson,
      force_FC = force_FC,
      sys = sys,
      sys_mem = sys_mem,
      quiet = quiet,
      gj2008 = gj2008
    )

    ret <- GeoJSON_to_sf(result, target_proj)

    # remove data slot if input didn't have one
    if (!has_data) {
      ret <- sf::st_geometry(ret)
    }  else {
      ret <- restore_classes(ret, classes)
    }

    ret
  }

union_sp <-
  function(
    target,
    overlay_layer,
    force_FC = TRUE,
    sys = FALSE,
    sys_mem = getOption("mapshaper.sys_mem", default = 8),
    quiet = getOption("mapshaper.sys_quiet", default = FALSE),
    gj2008 = FALSE
  ) {

    target_proj <-
      methods::slot(target, "proj4string")

    if (!is(overlay_layer, "SpatialPolygons")) stop("Input layers must be of class SpatialPolygons or SpatialPolygonsDataFrame")
    if (!sp::identicalCRS(target, overlay_layer)) {
      stop("Input layers do not have identical CRS.", call. = FALSE)
    }
    overlay_geojson <-
      sp_to_GeoJSON(overlay_layer, file = sys)

    target_geojson <-
      sp_to_GeoJSON(target, file = sys)

    result <- mapshaper_union(
      target_layer = target_geojson,
      overlay_layer = overlay_geojson,
      force_FC = force_FC,
      sys = sys,
      sys_mem = sys_mem,
      quiet = quiet,
      gj2008 = gj2008
    )

    ret <- GeoJSON_to_sp(result, target_proj)

    # remove data slot if input didn't have one
    if (!.hasSlot(target, "data")) {
      ret <- as(ret, class(target)[1])
    }

    ret

  }

mapshaper_union <-
  function(
    target_layer,
    overlay_layer,
    force_FC = TRUE,
    sys = T,
    sys_mem = getOption("mapshaper.sys_mem", default = 8),
    quiet = getOption("mapshaper.sys_quiet", default = FALSE),
    gj2008 = FALSE
  ) {

    if (sys) {
      on.exit(unlink(c(target_layer, overlay_layer)), add = TRUE)
      out <- sys_mapshaper_union(
        data = target_layer,
        data2 = overlay_layer,
        force_FC = force_FC,
        sys_mem = sys_mem,
        quiet = quiet,
        gj2008 = gj2008
      )
    } else {

      ms <- ms_make_ctx()
      ## Import the layers into the V8 session
      ms$assign("target_geojson", target_layer)
      ms$assign("overlay_geojson", overlay_layer)

      # Combine them into a single object
      ms$eval("
      var data_layers = {'target.json': target_geojson, 'overlay.json': overlay_geojson}
    ")

      ## Construct the command string; referring to layer names as assigned above
      command <- paste0("-i target.json overlay.json combine-files -", "union")

      command <- paste(command, "-o out.json format=geojson",
                       "geojson-type=FeatureCollection")

      if (force_FC) {
        # this must come after -o format=geojson
        command <- paste(command, fc_command())
      }

      if (isTRUE(gj2008)) {
        command <- paste(command, "gj2008")
      }

      # Create an object to hold the return value
      ms$eval("var return_data;")

      # Run the commands on the data
      ms$eval(paste0('mapshaper.applyCommands("',
                     command,
                     '", data_layers, ',
                     "function(Error, data) {\nif (Error) console.error('Error in V8 context: ' + Error.stack);\nreturn_data = data;\n}", ')'))

      out <- ms$get("return_data")[["out.json"]]
      out <- class_geo_json(out)
    }
  out
}

sys_mapshaper_union <- function(data,
                           data2 = NULL,
                           # command,
                           force_FC = TRUE, # default FALSE as in most cases it is added in apply_mapshaper_commands
                           sys_mem = getOption("mapshaper.sys_mem", default = 8),
                           quiet = getOption("mapshaper.sys_quiet", default = FALSE),
                           gj2008 = FALSE) {
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

  out_fc <- if (force_FC) fc_command() else NULL
  gj2008 <- if (gj2008) "gj2008" else NULL

  cmd_args <- c(
    sys_mem,
    shQuote(in_data_file),
    shQuote(in_data_file2), # will be NULL if no data2/in_data_file2
    command <- paste("combine-files", ms_compact("-union"), collapse = " "),
    "-o", shQuote(out_data_file),
    out_fc, # will be NULL if force_FC is FALSE
    gj2008, # will be NULL if gj2008 is FALSE
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
