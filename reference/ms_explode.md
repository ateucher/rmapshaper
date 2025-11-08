# Convert multipart lines or polygons to singlepart

For objects of class `Spatial` (e.g., `SpatialPolygonsDataFrame`), you
may find it faster to use
[`sp::disaggregate`](https://edzer.github.io/sp/reference/disaggregate.html).

## Usage

``` r
ms_explode(input, ...)
```

## Arguments

- input:

  One of:

  - `geo_json` or `character` multipart lines, or polygons;

  - multipart `SpatialPolygons`, `SpatialLines`;

  - `sf` or `sfc` multipart lines, or polygons object

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

same class as input

## Details

There is currently no method for SpatialMultiPoints

## Examples

``` r
library(geojsonsf)
library(sf)

poly <- "{\"type\":\"FeatureCollection\",\"features\":
          [\n{\"type\":\"Feature\",\"geometry\":{\"type\":
          \"MultiPolygon\",\"coordinates\":[[[[102,2],[102,3],
          [103,3],[103,2],[102,2]]],[[[100,0],[100,1],[101,1],
          [101,0],[100,0]]]]},\"properties\":{\"a\":0}}\n]}"

poly <- geojson_sf(poly)
plot(poly)

length(poly)
#> [1] 2
poly
#> Simple feature collection with 1 feature and 1 field
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 100 ymin: 0 xmax: 103 ymax: 3
#> Geodetic CRS:  WGS 84
#>   a                       geometry
#> 1 0 MULTIPOLYGON (((102 2, 102 ...

# Explode the polygon
out <- ms_explode(poly)
plot(out)

length(out)
#> [1] 2
out
#> Simple feature collection with 2 features and 1 field
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 100 ymin: 0 xmax: 103 ymax: 3
#> Geodetic CRS:  WGS 84
#>   a                       geometry
#> 1 0 POLYGON ((102 2, 103 2, 103...
#> 2 0 POLYGON ((100 0, 101 0, 101...
```
