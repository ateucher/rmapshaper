

#' run_mapshaper_command
#'
#' @param data
#' @param command
#'
#' @return geojson
#' @export
run_mapshaper_command <- function(data, command) {
  ms$eval(paste0('var command = mapshaper.internal.parseCommands("',
                  command, '")'))

  ms$eval(paste0('var data = ', data))

  out <- ms$get(
    "
    (function(){
      var return_data = {};
      mapshaper.runCommand(
        command[0],
        mapshaper.internal.importFileContent(data, null, {}),
        function(err,data){
          // This chunk from Mapshaper.ProcessFileContent to get output options:
          // if last command is -o, use -o options for exporting
          outCmd = command[command.length-1];
          if (outCmd && outCmd.name == 'o') {
            outOpts = command.pop().options;
          } else {
            outOpts = {};
          }
          // Convert dataset to geojson for export
          // (or if other format supplied in output options)
          return_data = mapshaper.internal.exportFileContent(data, outOpts);
        }
      )
    return return_data;
    })()
    "
  )

  as.list(out)
}