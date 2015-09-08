update_mapshaper <- function() {
  mapshaper_path <- "https://raw.githubusercontent.com/mbloch/mapshaper/master/mapshaper.js"
  mapshaper_local <- "inst/mapshaper/mapshaper.js"
  download.file(mapshaper_path, mapshaper_local)
}

update_mapshaper()
