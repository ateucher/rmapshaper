# #' run_mapshaper_command
# #'
# #' @param data
# #' @param command
# #'
# #' @return geojson
# #' @export
# run_mapshaper_command <- function(data, command) {
#   ms$eval(paste0('var command = mapshaper.internal.parseCommands("',
#                   command, '")'))
#
#   ms$eval(paste0('var data = ', data))
#
#   out <- ms$get(
#     "
#     (function(){
#       var return_data = {};
#       mapshaper.runCommand(
#         command[0],
#         mapshaper.internal.importFileContent(data, null, {}),
#         function(err,data){
#           // This chunk from Mapshaper.ProcessFileContent to get output options:
#           // if last command is -o, use -o options for exporting
#           outCmd = command[command.length-1];
#           if (outCmd && outCmd.name == 'o') {
#             outOpts = command.pop().options;
#           } else {
#             outOpts = {};
#           }
#           // Convert dataset to geojson for export
#           // (or if other format supplied in output options)
#           return_data = mapshaper.internal.exportFileContent(data, outOpts);
#         }
#       )
#     return return_data;
#     })()
#     "
#   )
#
#   as.list(out)
# }

#' apply_mapshaper_commands
#'
#' @param command
#' @param data
#'
#' @return geojson
#' @export
apply_mapshaper_commands <- function(command, data) {
  ms$eval("var return_data;")

  callback <- "function(Error, data) {
  if (Error) console.error(Error);
  return_data = data;
}"

  ms$call("mapshaper.applyCommands", command, data, JS(callback))
  ms$get("return_data")
}

#' @importFrom rgdal readOGR writeOGR
#' @importFrom sp proj4string proj4string<- CRS
GeoJSON_to_sp <- function(geojson, proj) {
  sp <- suppressMessages(readOGR(geojson, "OGRGeoJSON", verbose = FALSE))
  suppressMessages(
    suppressWarnings(proj4string(sp) <- CRS(proj))
  )
  sp
}

sp_to_GeoJSON <- function(sp){
  proj <- proj4string(sp)
  tf <- tempfile()
  writeOGR(sp, tf, layer = "geojson", driver = "GeoJSON")
  js <- paste(readLines(tf), collapse=" ")
  file.remove(tf)
  attr(js, "proj") <- proj
  js
}
