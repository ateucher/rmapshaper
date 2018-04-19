This is to test and try to debug [#76](https://github.com/ateucher/rmapshaper/issues/76), 
where inconsistent results are returned when using the internal mapshaper via 
`V8` vs using the system mapshaper by setting `sys = TRUE`.

Build the image from the Dockerfile and run the test script to reproduce the 
results reported in the issue:
```sh
$ Build the image
$ docker build -t fedr .

# Run the test script to see the results
$ docker run -it fedr Rscript test.R
trying URL 'https://github.com/ateucher/rmapshaper/files/1911058/statsnzregional-council-2018-clipped-generalised-GPKG.zip'
Content type 'application/zip' length 9863882 bytes (9.4 MB)
==================================================
downloaded 9.4 MB

Loading required package: methods
Linking to GEOS 3.6.1, GDAL 2.1.4, proj.4 4.9.3
Reading layer `regional_council_2018_clipped_generalised' from data source `/regional-council-2018-clipped-generalised.gpkg' using driver `GPKG'
Simple feature collection with 17 features and 5 fields
geometry type:  MULTIPOLYGON
dimension:      XY
bbox:           xmin: 1089970 ymin: 4747987 xmax: 2470042 ymax: 6223156
epsg (SRID):    2193
proj4string:    +proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs
[i] Snapped 9 points
[filter] Retained 17 of 17 features
[o] Wrote /tmp/Rtmp8PCgiT/file160d20d3c.geojson
original:14407.2 Kb
sys-false: 5470.3 Kb
sys-true: 39.9 Kb
```

Enter the running container to try to debug:
```sh
$ docker run -it fedr sh
```