# Create a line layer consisting of shared boundaries with no attribute data

Create a line layer consisting of shared boundaries with no attribute
data

## Usage

``` r
ms_innerlines(input, ...)
```

## Arguments

- input:

  input polygons object to convert to inner lines. One of:

  - `geo_json` or `character` polygons;

  - `SpatialPolygons*`;

  - `sf` or `sfc` polygons object

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

lines in the same class as the input layer, but without attributes

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
                  [102,1],[102,2],[103,2],[103,1],[102,1]
                  ]]}},
              {"type":"Feature",
                "properties":{"foo": "b"},
                "geometry":{"type":"Polygon","coordinates":[[
                  [103,1],[103,2],[104,2],[104,1],[103,1]
                  ]]}}]}', class = c("geojson", "json"))

poly <- geojson_sf(poly)
plot(poly)


out <- ms_innerlines(poly)
plot(out)

```
