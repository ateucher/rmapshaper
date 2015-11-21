<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/ateucher/rmapshaper.svg?branch=master)](https://travis-ci.org/ateucher/rmapshaper)

rmapshaper
----------

An R package providing access to the awesome [mapshaper](https://github.com/mbloch/mapshaper/) tool by Mattew Bloch, which has both a [Node.js command-line tool](https://github.com/mbloch/mapshaper/wiki/Introduction-to-the-Command-Line-Tool) as well as an [interactive web tool](http://mapshaper.org/).

I started this package so that I could have mapshaper's [Visvalingam](http://bost.ocks.org/mike/simplify/) simplification method available in R. There is, as far as I know, no other R package that performs topologically-aware multi-polygon simplification. (This means that shared boundaries between adjacent polygons are always kept intact, with no gaps or overlaps, even at high levels of simplification).

But mapshaper does much more than simplification, so I am working on wrapping most of the core functionality of mapshaper into R functions.

So far, it provides the following functions:

    ms_simplify
    ms_clip
    ms_erase
    ms_dissolve
    ms_explode

The package may be (is probably) buggy. If you run into any bugs, please file an [issue](https://github.com/ateucher/rmapshaper/issues/)

### Installation

`rmapshaper` is not on CRAN for now, but you can install it with `devtools`. You will also need at least version `0.1.5.9810` (current dev version) of [`geojsonio`](https://github.com/ropensci/geojsonio), also available from github:

``` r
## install.packages("devtools")
library(devtools)
install_github("ropensci/geojsonio")
install_github("ateucher/rmapshaper")
```

### Usage

rmapshaper works with geojson strings (character objects of class `geo_json`) and `list` geojson objects of class `geo_list`. These classes are defined in the `geojsonio` package. It also works with `Spatial` classes from the `sp` package.

We will use the `states` dataset from the `geojsonio` package and first turn it into a `geo_json` object:

``` r
library(geojsonio)
#> 
#> Attaching package: 'geojsonio'
#> 
#> The following object is masked from 'package:base':
#> 
#>     pretty
library(rmapshaper)
library(sp)

## First convert to json
states_json <- geojson_json(states, geometry = "polygon", group = "group")
#> Assuming 'long' and 'lat' are longitude and latitude, respectively

## For ease of illustration via plotting, we will convert to a `SpatialPolygonsDataFrame`:
states_sp <- geojson_sp(states_json)

## Plot the original
plot(states_sp)
```

![](fig/README-unnamed-chunk-2-1.png)

``` r

## Now simplify using default parameters, then plot the simplified states
states_simp <- ms_simplify(states_sp)
plot(states_simp)
```

![](fig/README-unnamed-chunk-2-2.png)

You can see that even at very high levels of simplification, the mapshaper simplification algorithm preserves the topology, including shared boudaries:

``` r
states_very_simp <- ms_simplify(states_sp, keep = 0.001)
plot(states_very_simp)
```

![](fig/README-unnamed-chunk-3-1.png)

Compare this to the output using `rgeos::gSimplify`, where overlaps and gaps are evident:

``` r
library(rgeos)
#> rgeos version: 0.3-11, (SVN revision 479)
#>  GEOS runtime version: 3.4.2-CAPI-1.8.2 r3921 
#>  Linking to sp version: 1.1-0 
#>  Polygon checking: TRUE
states_gsimp <- gSimplify(states_sp, tol = 1, topologyPreserve = TRUE)
plot(states_gsimp)
```

![](fig/README-unnamed-chunk-4-1.png)

### Thanks

This package uses the [V8](https://cran.r-project.org/web/packages/V8/index.html) package to provide an environment in which to run mapshaper's javascript code in R. It relies heavily on all of the great spatial packages that already exist (especially `sp` and `rgdal`), the `geojsonio` package for converting between geo\_list, geo\_json, and `sp` objects, and the `jsonlite` package for converting between json strings and R objects.

Thanks to [timelyportfolio](https://github.com/timelyportfolio) for helping me wrangle the javascript to the point where it works in V8. He also wrote the [mapshaper htmlwidget](https://github.com/timelyportfolio/mapshaper_htmlwidget), which provides access to the mapshaper web inteface, right in your R session. We have plans to combine the two in the future.

### LICENSE

MIT
