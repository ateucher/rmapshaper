## Borrowed verbatim from geojsonio:
## https://github.com/ropensci/geojsonio/blob/321c679057e2dde282e564f3c845dea7f280ccf9/R/as_spatial_methods.R

## SpatialPoints to SpatialPointsDataFrame
as.SpatialPointsDataFrame.SpatialPoints <- function(from) {
  if (!requireNamespace("sp", quietly = TRUE)) {
    stop("Package sp required. Please install.")
  }
  ids <- rownames(slot(from, "coords"))
  if (is.null(ids)) {
    ids <- 1:NROW(slot(from, "coords"))
  }
  df <- data.frame(dummy = rep(0, length(ids)), row.names = ids)
  sp::SpatialPointsDataFrame(from, df)
}

setAs(
  "SpatialPoints", "SpatialPointsDataFrame",
  as.SpatialPointsDataFrame.SpatialPoints
)


## SpatialLines to SpatialLinesDataFrame
as.SpatialLinesDataFrame.SpatialLines <- function(from) {
  if (!requireNamespace("sp", quietly = TRUE)) {
    stop("Package sp required. Please install.")
  }
  IDs <- sapply(slot(from, "lines"), function(x) slot(x, "ID"))
  df <- data.frame(dummy = rep(0, length(IDs)), row.names = IDs)
  sp::SpatialLinesDataFrame(from, df)
}

setAs(
  "SpatialLines", "SpatialLinesDataFrame",
  as.SpatialLinesDataFrame.SpatialLines
)