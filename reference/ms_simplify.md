# Topologically-aware geometry simplification.

Uses [mapshaper](https://github.com/mbloch/mapshaper) to simplify
polygons.

## Usage

``` r
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
```

## Arguments

- input:

  spatial object to simplify. One of:

  - `geo_json` or `character` polygons or lines;

  - `SpatialPolygons*` or `SpatialLines*`;

  - `sf` or `sfc` polygons or lines object

- keep:

  proportion of points to retain (0-1; default 0.05)

- method:

  simplification method to use: `"vis"` for Visvalingam algorithm, or
  `"dp"` for Douglas-Peuker algorithm. If left as `NULL` (default), uses
  Visvalingam simplification but modifies the area metric by
  underweighting the effective area of points at the vertex of more
  acute angles, resulting in a smoother appearance. See this
  <https://github.com/mbloch/mapshaper/wiki/Simplification-Tips>link for
  more information.

- weighting:

  Coefficient for weighting Visvalingam simplification (default is 0.7).
  Higher values produce smoother output. weighting=0 is equivalent to
  unweighted Visvalingam simplification.

- keep_shapes:

  Prevent small polygon features from disappearing at high
  simplification (default `FALSE`)

- no_repair:

  disable intersection repair after simplification (default `FALSE`).

- snap:

  Snap together vertices within a small distance threshold to fix small
  coordinate misalignment in adjacent polygons. Default `TRUE`.

- explode:

  Should multipart polygons be converted to singlepart polygons? This
  prevents small shapes from disappearing during simplification if
  `keep_shapes = TRUE`. Default `FALSE`

- drop_null_geometries:

  should Features with null geometries be dropped? Ignored for
  `Spatial*` objects, as it is always `TRUE`.

- snap_interval:

  Specify snapping distance in source units, must be a numeric. Default
  `NULL`

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

a simplified representation of the geometry in the same class as the
input

## Examples

``` r
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
#> {"type":"FeatureCollection", "features": [
#> {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[-70.603637,-33.399918],[-70.697021,-33.419406],[-70.668869,-33.472117],[-70.609817,-33.468107],[-70.603637,-33.399918]]]},"properties":null}
#> ]} 

# With an sf object

poly_sf <- geojsonsf::geojson_sf(poly)
ms_simplify(poly_sf, keep = 0.5)
#> Simple feature collection with 1 feature and 0 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -70.70045 ymin: -33.47212 xmax: -70.58716 ymax: -33.39247
#> Geodetic CRS:  WGS 84
#>                         geometry
#> 1 POLYGON ((-70.60364 -33.399...
```
