# Remove features or portions of features that fall outside a clipping area.

Removes portions of the target layer that fall outside the clipping
layer or bounding box.

## Usage

``` r
ms_clip(target, clip = NULL, bbox = NULL, remove_slivers = FALSE, ...)
```

## Arguments

- target:

  the target layer from which to remove portions. One of:

  - `geo_json` or `character` points, lines, or polygons;

  - `SpatialPolygons`, `SpatialLines`, `SpatialPoints`;

  - `sf` or `sfc` points, lines, or polygons object

- clip:

  the clipping layer (polygon). One of:

  - `geo_json` or `character` polygons;

  - `SpatialPolygons*`;

  - `sf` or `sfc` polygons object

- bbox:

  supply a bounding box instead of a clipping layer to extract from the
  target layer. Supply as a numeric vector: `c(minX, minY, maxX, maxY)`.

- remove_slivers:

  Remove tiny sliver polygons created by clipping. (Default `FALSE`)

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

clipped target in the same class as the input target

## Examples

``` r
if (rmapshaper:::v8_version() >= "6") {
  library(geojsonsf, quietly = TRUE)
  library(sf)

  poly <- structure("{\"type\":\"FeatureCollection\",
    \"features\":[{\"type\":\"Feature\",\"properties\":{},
    \"geometry\":{\"type\":\"Polygon\",\"coordinates\":
    [[[52.8658,-44.7219],[53.7702,-40.4873],[55.3204,-37.5579],
    [56.2757,-37.917],[56.184,-40.6443],[61.0835,-40.7529],
    [58.0202,-43.634],[61.6699,-45.0678],[62.737,-46.2841],
    [55.7763,-46.2637],[54.9742,-49.1184],[52.799,-45.9386],
    [52.0329,-49.5677],[50.1747,-52.1814],[49.0098,-52.3641],
    [52.7068,-45.7639],[43.2278,-47.1908],[48.4755,-45.1388],
    [50.327,-43.5207],[48.0804,-41.2784],[49.6307,-40.6159],
    [52.8658,-44.7219]]]}}]}", class = c("geojson", "json"))
  poly <- geojson_sf(poly)
  plot(poly)

  clip_poly <- structure('{
  "type": "Feature",
  "properties": {},
  "geometry": {
  "type": "Polygon",
  "coordinates": [
  [
  [51, -40],
  [55, -40],
  [55, -45],
  [51, -45],
  [51, -40]
  ]
  ]
  }
  }', class = c("geojson", "json"))
  clip_poly <- geojson_sf(clip_poly)
  plot(clip_poly)

  out <- ms_clip(poly, clip_poly)
  plot(out, add = TRUE)
}
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE


```
