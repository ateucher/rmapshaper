% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/points.R
\name{ms_points}
\alias{ms_points}
\title{Create points from a polygon layer}
\usage{
ms_points(input, location = NULL, x = NULL, y = NULL, ...)
}
\arguments{
\item{input}{input polygons object to convert to points. One of:
\itemize{
\item \code{geo_json} or \code{character} polygons;
\item \code{SpatialPolygons*};
\item \code{sf} or \code{sfc} polygons object
}}

\item{location}{either \code{"centroid"} or \code{"inner"}. If
\code{"centroid"}, creates points at the centroid of the largest ring of
each polygon feature. if \code{"inner"}, creates points in the interior of
the largest ring of each polygon feature. Inner points are located away
from polygon boundaries. Must be \code{NULL} if \code{x} and \code{y} are
specified. If left as \code{NULL} (default), will use centroids.}

\item{x}{name of field containing x coordinate values. Must be \code{NULL} if
\code{location} is specified.}

\item{y}{name of field containing y coordinate values. Must be \code{NULL} if
\code{location} is specified.}

\item{...}{
  Arguments passed on to \code{\link[=apply_mapshaper_commands]{apply_mapshaper_commands}}
  \describe{
    \item{\code{force_FC}}{should the output be forced to be a FeatureCollection (or sf
object or Spatial*DataFrame) even if there are no attributes? Default
\code{TRUE}. If FALSE and there are no attributes associated with the
geometries, a GeometryCollection (or Spatial object with no dataframe, or
sfc) will be output.}
    \item{\code{sys}}{Should the system mapshaper be used instead of the bundled
mapshaper? Gives better performance on large files. Requires the mapshaper
node package to be installed and on the PATH.}
    \item{\code{sys_mem}}{How much memory (in GB) should be allocated if using the
system mapshaper (\code{sys = TRUE})? Default 8. Ignored if \code{sys = FALSE}. This
can also be set globally with the option \code{"mapshaper.sys_mem"}}
    \item{\code{quiet}}{If \code{sys = TRUE}, should the mapshaper messages be silenced?
Default \code{FALSE}. This can also be set globally with the option
\code{"mapshaper.sys_quiet"}}
    \item{\code{gj2008}}{Generate output that is consistent with the pre-RFC 7946
GeoJSON spec (dating to 2008). Polygon rings are CW and holes are CCW,
which is the opposite of the default RFC 7946-compatible output. This should
be rarely needed, though may be useful when preparing data for D3-based
data visualizations (such as \code{plotly::plot_ly()}). Default \code{FALSE}}
  }}
}
\value{
points in the same class as the input.
}
\description{
Can be generated from the polygons by specifying \code{location} to be
\code{"centroid"} or \code{"inner"}, OR by specifying fields in the
attributes of the layer containing \code{x} and \code{y} coordinates.
}
\examples{
library(geojsonsf)
library(sf)

poly <- structure("{\"type\":\"FeatureCollection\",
           \"features\":[{\"type\":\"Feature\",\"properties\":
           {\"x_pos\": 1, \"y_pos\": 2},
           \"geometry\":{\"type\":\"Polygon\",
           \"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}},
           {\"type\":\"Feature\",\"properties\":{\"x_pos\": 3, \"y_pos\": 4},
           \"geometry\":{\"type\":\"Polygon\",
           \"coordinates\":[[[100,2],[98,4],[101.5,4],[100,2]]]}},
           {\"type\":\"Feature\",\"properties\":{\"x_pos\": 5, \"y_pos\": 6},
           \"geometry\":{\"type\":\"Polygon\",
           \"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]}}]}",
           class = c("geojson", "json"))

poly <- geojson_sf(poly)
summary(poly)
plot(poly)

# Convert to points using centroids
out <- ms_points(poly, location = "centroid")
summary(out)
plot(out)

# Can also specify locations using attributes in the data
out <- ms_points(poly, x = "x_pos", y = "y_pos")
summary(out)
plot(out)

}
