% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{apply_mapshaper_commands}
\alias{apply_mapshaper_commands}
\title{Apply a mapshaper command string to a geojson object}
\usage{
apply_mapshaper_commands(
  data,
  command,
  force_FC = TRUE,
  sys = FALSE,
  sys_mem = getOption("mapshaper.sys_mem", default = 8),
  quiet = getOption("mapshaper.sys_quiet", default = FALSE),
  gj2008 = FALSE
)
}
\arguments{
\item{data}{character containing geojson or path to geojson file. If a file
path, \code{sys} must be true.}

\item{command}{valid mapshaper command string}

\item{force_FC}{should the output be forced to be a FeatureCollection (or sf
object or Spatial*DataFrame) even if there are no attributes? Default
\code{TRUE}. If FALSE and there are no attributes associated with the
geometries, a GeometryCollection (or Spatial object with no dataframe, or
sfc) will be output.}

\item{sys}{Should the system mapshaper be used instead of the bundled
mapshaper? Gives better performance on large files. Requires the mapshaper
node package to be installed and on the PATH.}

\item{sys_mem}{How much memory (in GB) should be allocated if using the
system mapshaper (\code{sys = TRUE})? Default 8. Ignored if \code{sys = FALSE}. This
can also be set globally with the option \code{"mapshaper.sys_mem"}}

\item{quiet}{If \code{sys = TRUE}, should the mapshaper messages be silenced?
Default \code{FALSE}. This can also be set globally with the option
\code{"mapshaper.sys_quiet"}}

\item{gj2008}{Generate output that is consistent with the pre-RFC 7946
GeoJSON spec (dating to 2008). Polygon rings are CW and holes are CCW,
which is the opposite of the default RFC 7946-compatible output. This should
be rarely needed, though may be useful when preparing data for D3-based
data visualizations (such as \code{plotly::plot_ly()}). Default \code{FALSE}}
}
\value{
geojson
}
\description{
Apply a mapshaper command string to a geojson object
}
\examples{

nc <- sf::read_sf(system.file("gpkg/nc.gpkg", package = "sf"))
rmapshaper::apply_mapshaper_commands(geojsonsf::sf_geojson(nc), "-clean")

}
