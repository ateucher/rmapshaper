# Remove small detached polygons (islands)

Remove small detached polygons, keeping those with a minimum area and/or
a minimum number of vertices. Optionally remove null geometries.

## Usage

``` r
ms_filter_islands(
  input,
  min_area = NULL,
  min_vertices = NULL,
  drop_null_geometries = TRUE,
  ...
)
```

## Arguments

- input:

  spatial object to filter. One of:

  - `geo_json` or `character` polygons;

  - `SpatialPolygons*`;

  - `sf` or `sfc` polygons object

- min_area:

  minimum area of polygons to retain. Area is calculated using planar
  geometry, except for the area of unprojected polygons, which is
  calculated using spherical geometry in units of square meters.

- min_vertices:

  minimum number of vertices in polygons to retain.

- drop_null_geometries:

  should features with empty geometries be dropped? Default `TRUE`.
  Ignored for `SpatialPolyons*`, as it is always `TRUE`.

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

object with only specified features retained, in the same class as the
input

## Examples

``` r
library(geojsonsf)
library(sf)

poly <- structure("{\"type\":\"FeatureCollection\",
           \"features\":[{\"type\":\"Feature\",\"properties\":{},
           \"geometry\":{\"type\":\"Polygon\",
           \"coordinates\":[[[102,2],[102,4],[104,4],[104,2],[102,2]]]}},
           {\"type\":\"Feature\",\"properties\":{},
           \"geometry\":{\"type\":\"Polygon\",
           \"coordinates\":[[[100,2],[98,4],[101.5,4],[100,2]]]}},
           {\"type\":\"Feature\",\"properties\":{},
           \"geometry\":{\"type\":\"Polygon\",
           \"coordinates\":[[[100,0],[100,1],[101,1],[101,0],[100,0]]]}}]}",
           class = c("geojson", "json"))

poly <- geojson_sf(poly)
plot(poly)


out <- ms_filter_islands(poly, min_area = 12391399903)
plot(out)

```
