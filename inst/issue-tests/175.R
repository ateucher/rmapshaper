library(sf)
library(geojsonsf)
# library(rmapshaper)
devtools::load_all()

check_sys_mapshaper()

MySfLayer <- st_read("~/Downloads/MyLayers/MySfLayer.gpkg")
MySfClippingLayer <- st_read("~/Downloads/MyLayers/MySfClippingLayer.gpkg")

MySfLayerWGS <- st_transform(MySfLayer, crs = 4326)
MySfClippingLayerWGS <- st_transform(MySfClippingLayer, crs = 4326)

# tictoc::tic()
ClipSf <- ms_clip(
  MySfLayerWGS,
  MySfClippingLayerWGS,
  sys = TRUE,
  sys_mem = 16
)
# tictoc::toc()

system.time(
  rmapshaper:::sf_to_GeoJSON(MySfLayer, file = TRUE)
)

MyGeoJLayer <- sf_geojson(MySfLayer, simplify = FALSE)
MyGeoJLayerWGS <- sf_geojson(MySfLayerWGS, simplify = FALSE)
MyGeoJClippingLayerWGS <- sf_geojson(MySfClippingLayerWGS, simplify = FALSE)

tictoc::tic()
ClipGeoJ <- ms_clip(
  MyGeoJLayerWGS,
  MyGeoJClippingLayerWGS,
  sys = TRUE,
  sys_mem = 16
)
tictoc::toc()
