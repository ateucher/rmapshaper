# Convert polygons to topological boundaries (lines)

Convert polygons to topological boundaries (lines)

## Usage

``` r
ms_lines(input, fields = NULL, ...)
```

## Arguments

- input:

  input polygons object to convert to inner lines. One of:

  - `geo_json` or `character` polygons;

  - `SpatialPolygons*`;

  - `sf` or `sfc` polygons object

- fields:

  character vector of field names. If left as `NULL` (default), external
  (unshared) boundaries are attributed as TYPE 0 and internal (shared)
  boundaries are TYPE 1. Giving a field name adds an intermediate level
  of hierarchy at TYPE 1, with the lowest-level internal boundaries set
  to TYPE 2. Supplying a character vector of field names adds additional
  levels of hierarchy.

- ...:

  Arguments passed on to
  [`apply_mapshaper_commands`](http://andyteucher.ca/rmapshaper/reference/apply_mapshaper_commands.md)

  `force_FC`

  :   should the output be forced to be a FeatureCollection (or sf
      object or Spatial\*DataFrame) even if there are no attributes?
      Default `TRUE`. If FALSE and there are no attributes associated
      with the geometries, a GeometryCollection (or Spatial object with
      no dataframe, or sfc) will be output.

  `sys`

  :   Should the system mapshaper be used instead of the bundled
      mapshaper? Gives better performance on large files. Requires the
      mapshaper node package to be installed and on the PATH.

  `sys_mem`

  :   How much memory (in GB) should be allocated if using the system
      mapshaper (`sys = TRUE`)? Default 8. Ignored if `sys = FALSE`.
      This can also be set globally with the option
      `"mapshaper.sys_mem"`

  `quiet`

  :   If `sys = TRUE`, should the mapshaper messages be silenced?
      Default `FALSE`. This can also be set globally with the option
      `"mapshaper.sys_quiet"`

  `gj2008`

  :   Generate output that is consistent with the pre-RFC 7946 GeoJSON
      spec (dating to 2008). Polygon rings are CW and holes are CCW,
      which is the opposite of the default RFC 7946-compatible output.
      This should be rarely needed, though may be useful when preparing
      data for D3-based data visualizations (such as
      `plotly::plot_ly()`). Default `FALSE`

## Value

topological boundaries as lines, in the same class as the input

## Examples

``` r
library(geojsonsf)
library(sf)

poly <- structure('{"type":"FeatureCollection",
             "features":[
             {"type":"Feature",
             "properties":{"foo": "a"},
             "geometry":{"type":"Polygon","coordinates":[[
             [102,2],[102,3],[103,3],[103,2],[102,2]
             ]]}}
             ,{"type":"Feature",
             "properties":{"foo": "a"},
             "geometry":{"type":"Polygon","coordinates":[[
             [103,3],[104,3],[104,2],[103,2],[103,3]
             ]]}},
             {"type":"Feature",
             "properties":{"foo": "b"},
             "geometry":{"type":"Polygon","coordinates":[[
             [102.5,1],[102.5,2],[103.5,2],[103.5,1],[102.5,1]
             ]]}}]}', class = c("geojson", "json"))

poly <- geojson_sf(poly)
summary(poly)
#>      foo                     geometry
#>  Length:3           POLYGON      :3  
#>  Class :character   epsg:4326    :0  
#>  Mode  :character   +proj=long...:0  
plot(poly)


out <- ms_lines(poly)
summary(out)
#>       RANK          TYPE                    geometry
#>  Min.   :0.00   Length:4           LINESTRING   :4  
#>  1st Qu.:0.00   Class :character   epsg:4326    :0  
#>  Median :0.00   Mode  :character   +proj=long...:0  
#>  Mean   :0.25                                       
#>  3rd Qu.:0.25                                       
#>  Max.   :1.00                                       
plot(out)

```
