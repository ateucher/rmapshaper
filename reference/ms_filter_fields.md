# Delete fields in the attribute table

Removes all fields except those listed in the `fields` parameter

## Usage

``` r
ms_filter_fields(input, fields, ...)
```

## Arguments

- input:

  spatial object to filter fields on. One of:

  - `geo_json` or `character` points, lines, or polygons;

  - `SpatialPolygonsDataFrame`, `SpatialLinesDataFrame`,
    `SpatialPointsDataFrame`;

  - `sf` object

- fields:

  character vector of fields to retain.

- ...:

  Arguments passed on to
  [`apply_mapshaper_commands`](http://andyteucher.ca/rmapshaper/reference/apply_mapshaper_commands.md)

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

## Value

object with only specified attributes retained, in the same class as the
input

## Examples

``` r
library(geojsonsf)
library(sf)

poly <- structure("{\"type\":\"FeatureCollection\",
                  \"features\":[{\"type\":\"Feature\",
                  \"properties\":{\"a\": 1, \"b\":2, \"c\": 3},
                  \"geometry\":{\"type\":\"Polygon\",
                  \"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}}]}",
                  class = c("geojson", "json"))
poly <- geojson_sf(poly)
poly
#> Simple feature collection with 1 feature and 3 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 102 ymin: 2 xmax: 104 ymax: 4
#> Geodetic CRS:  WGS 84
#>   a b c                       geometry
#> 1 1 2 3 POLYGON ((102 2, 102 4, 104...

# Filter (keep) fields a and b, drop c
out <- ms_filter_fields(poly, c("a", "b"))
out
#> Simple feature collection with 1 feature and 2 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 102 ymin: 2 xmax: 104 ymax: 4
#> Geodetic CRS:  WGS 84
#>   a b                       geometry
#> 1 1 2 POLYGON ((102 2, 102 4, 104...
```
