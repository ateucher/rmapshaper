#' ---
#' output: github_document
#' ---

library(sf)
library(geojsonio)
library(sp)
library(rgdal)
devtools::load_all()

u = "https://borders.ukdataservice.ac.uk/ukborders/easy_download/prebuilt/shape/England_caswa_2001_clipped.zip"
# download.file(u, destfile = "zipped_shapefile.zip")
unzip("zipped_shapefile.zip")
f = list.files(pattern = ".shp")

# sf
res = sf::st_read(f)

res_simp <- ms_simplify(res, sys = TRUE)

## Test converting sf to geojson object
system.time(js_gjio <- geojson_json(res_simp))

system.time(js_int <- sf_to_GeoJSON(res_simp))

all.equal(as.character(js_gjio), as.character(js_int))

## Test writing sf to geojson file
system.time(st_write(res, tempfile(fileext = ".geojson")))

system.time(sf_sp_to_tempfile(res))

system.time(
  jsonlite::write_json(unclass(geojson_list(res)), path = tempfile(fileext = ".geojson"),
                       auto_unbox = TRUE, digits = 7)
)

# sp
res_sp <- as(res, "Spatial")
res_sp_simp <- as(res_simp, "Spatial")

## Test converting sf to geojson object
system.time(js_gjio <- geojson_json(res_sp_simp))

system.time(js_int <- sp_to_GeoJSON(res_sp_simp))

## Test writing sp to geojson file
f <- tempfile()
system.time(
  writeOGR(res_sp, paste0(f, ".geojson"), basename(f), driver = "GeoJSON",
                  check_exists = FALSE)
)

system.time(sf_sp_to_tempfile(res_sp))
