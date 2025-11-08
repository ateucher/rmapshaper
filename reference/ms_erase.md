# Remove features or portions of features that fall inside a specified area

Removes portions of the target layer that fall inside the erasing layer
or bounding box.

## Usage

``` r
ms_erase(target, erase = NULL, bbox = NULL, remove_slivers = FALSE, ...)
```

## Arguments

- target:

  the target layer from which to remove portions. One of:

  - `geo_json` or `character` points, lines, or polygons;

  - `SpatialPolygons`, `SpatialLines`, `SpatialPoints`

- erase:

  the erase layer (polygon). One of:

  - `geo_json` or `character` polygons;

  - `SpatialPolygons*`

- bbox:

  supply a bounding box instead of an erasing layer to remove from the
  target layer. Supply as a numeric vector: `c(minX, minY, maxX, maxY)`.

- remove_slivers:

  Remove tiny sliver polygons created by erasing. (Default `FALSE`)

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

erased target in the same format as the input target

## Examples

``` r
if (rmapshaper:::v8_version() >= "6") {
  library(geojsonsf, quietly = TRUE)
  library(sf)

  points <- structure("{\"type\":\"FeatureCollection\",
    \"features\":[{\"type\":\"Feature\",\"properties\":{},
    \"geometry\":{\"type\":\"Point\",\"coordinates\":
    [52.8658,-44.7219]}},{\"type\":\"Feature\",\"properties\":{},
    \"geometry\":{\"type\":\"Point\",\"coordinates\":
    [53.7702,-40.4873]}},{\"type\":\"Feature\",\"properties\":{},
    \"geometry\":{\"type\":\"Point\",\"coordinates\":[55.3204,-37.5579]}},
    {\"type\":\"Feature\",\"properties\":{},\"geometry\":
    {\"type\":\"Point\",\"coordinates\":[56.2757,-37.917]}},
    {\"type\":\"Feature\",\"properties\":{},\"geometry\":
    {\"type\":\"Point\",\"coordinates\":[56.184,-40.6443]}},
    {\"type\":\"Feature\",\"properties\":{},\"geometry\":
    {\"type\":\"Point\",\"coordinates\":[61.0835,-40.7529]}},
    {\"type\":\"Feature\",\"properties\":{},\"geometry\":
    {\"type\":\"Point\",\"coordinates\":[58.0202,-43.634]}}]}",
    class = c("geojson", "json"))
  points <- geojson_sf(points)
  plot(points)

  erase_poly <- structure('{
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
  erase_poly <- geojson_sf(erase_poly)

  out <- ms_erase(points, erase_poly)
  plot(out, add = TRUE)
}

```
