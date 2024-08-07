% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simplify.R
\name{ms_simplify}
\alias{ms_simplify}
\title{Topologically-aware geometry simplification.}
\usage{
ms_simplify(
  input,
  keep = 0.05,
  method = NULL,
  weighting = 0.7,
  keep_shapes = FALSE,
  no_repair = FALSE,
  snap = TRUE,
  explode = FALSE,
  drop_null_geometries = TRUE,
  snap_interval = NULL,
  ...
)
}
\arguments{
\item{input}{spatial object to simplify. One of:
\itemize{
\item \code{geo_json} or \code{character} polygons or lines;
\item \code{SpatialPolygons*} or \code{SpatialLines*};
\item \code{sf} or \code{sfc} polygons or lines object
}}

\item{keep}{proportion of points to retain (0-1; default 0.05)}

\item{method}{simplification method to use: \code{"vis"} for Visvalingam
algorithm, or \code{"dp"} for Douglas-Peuker algorithm. If left as
\code{NULL} (default), uses Visvalingam simplification but modifies the
area metric by underweighting the effective area of points at the vertex of
more acute angles, resulting in a smoother appearance. See this
\url{https://github.com/mbloch/mapshaper/wiki/Simplification-Tips}{link}
for more information.}

\item{weighting}{Coefficient for weighting Visvalingam simplification
(default is 0.7). Higher values produce smoother output. weighting=0 is
equivalent to unweighted Visvalingam simplification.}

\item{keep_shapes}{Prevent small polygon features from disappearing at high
simplification (default \code{FALSE})}

\item{no_repair}{disable intersection repair after simplification (default
\code{FALSE}).}

\item{snap}{Snap together vertices within a small distance threshold to fix
small coordinate misalignment in adjacent polygons. Default \code{TRUE}.}

\item{explode}{Should multipart polygons be converted to singlepart polygons?
This prevents small shapes from disappearing during simplification if
\code{keep_shapes = TRUE}. Default \code{FALSE}}

\item{drop_null_geometries}{should Features with null geometries be dropped?
Ignored for \code{Spatial*} objects, as it is always \code{TRUE}.}

\item{snap_interval}{Specify snapping distance in source units, must be a
numeric. Default \code{NULL}}

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
a simplified representation of the geometry in the same class as the
input
}
\description{
Uses \href{https://github.com/mbloch/mapshaper}{mapshaper} to simplify
polygons.
}
\examples{
# With a simple geojson object
poly <- structure('{
 "type": "Feature",
 "properties": {},
 "geometry": {
   "type": "Polygon",
   "coordinates": [[
     [-70.603637, -33.399918],
     [-70.614624, -33.395332],
     [-70.639343, -33.392466],
     [-70.659942, -33.394759],
     [-70.683975, -33.404504],
     [-70.697021, -33.419406],
     [-70.701141, -33.434306],
     [-70.700454, -33.446339],
     [-70.694274, -33.458369],
     [-70.682601, -33.465816],
     [-70.668869, -33.472117],
     [-70.646209, -33.473835],
     [-70.624923, -33.472117],
     [-70.609817, -33.468107],
     [-70.595397, -33.458369],
     [-70.587158, -33.442901],
     [-70.587158, -33.426283],
     [-70.590591, -33.414248],
     [-70.594711, -33.406224],
     [-70.603637, -33.399918]
   ]]
 }
}', class = c("geojson", "json"))

ms_simplify(poly, keep = 0.1)

# With an sf object

poly_sf <- geojsonsf::geojson_sf(poly)
ms_simplify(poly_sf, keep = 0.5)

}
