test\_conversion\_performance.R
================
ateucher
Mon Feb 5 15:02:19 2018

``` r
library(sf)
```

    ## Linking to GEOS 3.6.2, GDAL 2.2.3, proj.4 4.9.3

``` r
library(geojsonio)
```

    ## 
    ## Attaching package: 'geojsonio'

    ## The following object is masked from 'package:devtools':
    ## 
    ##     lint

    ## The following object is masked from 'package:base':
    ## 
    ##     pretty

``` r
library(sp)
library(rgdal)
```

    ## rgdal: version: 1.2-16, (SVN revision 701)
    ##  Geospatial Data Abstraction Library extensions to R successfully loaded
    ##  Loaded GDAL runtime: GDAL 2.2.3, released 2017/11/20
    ##  Path to GDAL shared files: /usr/local/Cellar/gdal2/2.2.3/share/gdal
    ##  GDAL binary built with GEOS: TRUE 
    ##  Loaded PROJ.4 runtime: Rel. 4.9.3, 15 August 2016, [PJ_VERSION: 493]
    ##  Path to PROJ.4 shared files: (autodetected)
    ##  Linking to sp version: 1.2-6

``` r
devtools::load_all()
```

    ## Loading rmapshaper

``` r
u = "https://borders.ukdataservice.ac.uk/ukborders/easy_download/prebuilt/shape/England_caswa_2001_clipped.zip"
# download.file(u, destfile = "zipped_shapefile.zip")
unzip("zipped_shapefile.zip")
f = list.files(pattern = ".shp")

# sf
res = sf::st_read(f)
```

    ## Reading layer `england_caswa_2001_clipped' from data source `/Users/ateucher/dev/rmapshaper/scratch/england_caswa_2001_clipped.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 6930 features and 5 fields
    ## geometry type:  MULTIPOLYGON
    ## dimension:      XY
    ## bbox:           xmin: 85665 ymin: 7054 xmax: 655604 ymax: 657534.1
    ## epsg (SRID):    NA
    ## proj4string:    +proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +datum=OSGB36 +units=m +no_defs

``` r
res_simp <- ms_simplify(res, sys = TRUE)

## Test converting sf to geojson object
system.time(js_gjio <- geojson_json(res_simp))
```

    ##    user  system elapsed 
    ##  15.235   1.107  16.350

``` r
system.time(js_int <- sf_to_GeoJSON(res_simp))
```

    ##    user  system elapsed 
    ##   7.270   0.052   7.324

``` r
all.equal(as.character(js_gjio), as.character(js_int))
```

    ## [1] TRUE

``` r
## Test writing sf to geojson file
system.time(st_write(res, tempfile(fileext = ".geojson")))
```

    ## Writing layer `filed86d3f87d11c' to data source `/var/folders/2w/x5wq73f93yzgm7hjr_b_54q00000gp/T//RtmpaXfErf/filed86d3f87d11c.geojson' using driver `GeoJSON'
    ## features:       6930
    ## fields:         5
    ## geometry type:  Multi Polygon

    ##    user  system elapsed 
    ##  44.657   2.041  46.906

``` r
system.time(sf_sp_to_tempfile(res))
```

    ##    user  system elapsed 
    ##  43.767   1.725  45.781

``` r
system.time(
  jsonlite::write_json(unclass(geojson_list(res)), path = tempfile(fileext = ".geojson"),
                       auto_unbox = TRUE, digits = 7)
)
```

    ##    user  system elapsed 
    ##  44.125   1.766  46.140

``` r
# sp
res_sp <- as(res, "Spatial")
res_sp_simp <- as(res_simp, "Spatial")

## Test converting sf to geojson object
system.time(js_gjio <- geojson_json(res_sp_simp))
```

    ##    user  system elapsed 
    ##  16.464   1.268  17.822

``` r
system.time(js_int <- sp_to_GeoJSON(res_sp_simp))
```

    ##    user  system elapsed 
    ##   2.862   0.159   3.040

``` r
## Test writing sp to geojson file
f <- tempfile()
system.time(
  writeOGR(res_sp, paste0(f, ".geojson"), basename(f), driver = "GeoJSON",
                  check_exists = FALSE)
)
```

    ##    user  system elapsed 
    ##  45.190   2.118  47.674

``` r
system.time(sf_sp_to_tempfile(res_sp))
```

    ##    user  system elapsed 
    ##  45.972   3.306  49.761
