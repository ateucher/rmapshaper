[![Travis-CI Build Status](https://travis-ci.org/ateucher/rmapshaper.svg?branch=test-v8)](https://travis-ci.org/ateucher/rmapshaper)

## rmapshaper

An R package providing access to the awesome [mapshaper](https://github.com/mbloch/mapshaper/) tool by Mattew Bloch, which has both a [Node.js command-line tool](https://github.com/mbloch/mapshaper/wiki/Introduction-to-the-Command-Line-Tool) as well as an [interactive web tool](http://mapshaper.org/).

I started this package so that I could have mapshaper's [Visvalingam](http://bost.ocks.org/mike/simplify/) simplification method available in R. There is, as far as I know, no other R package that performs topologically-aware multi-polygon simplification. (This means that shared boundaries between adjacent polygons are always kept intact, with no gaps or overlaps, even at high levels of simplification).

But mapshaper does much more than simplification, so I am working on wrapping 
most of the core functionality of mapshaper into R functions.

So far, it provides the following functions:

```
ms_simplify
ms_clip
ms_erase
ms_dissolve
ms_explode
```

The package may be (is probably) buggy. If you run into any bugs, please file an [issue](https://github.com/ateucher/rmapshaper/issues/)

### Installation

`rmapshaper` is not on CRAN for now, but you can install it with `devtools`. 
You will also need at least version `0.1.5.9810` (current dev version) of 
[`geojsonio`](https://github.com/ropensci/geojsonio), also available from github:

```r
## install.packages("devtools")
library(devtools)
install_github("ropensci/geojsonio")
install_github("ateucher/rmapshaper", ref = "test-v8")
```

### Thanks

This package uses the [V8](https://cran.r-project.org/web/packages/V8/index.html) package to provide an environment in which to run mapshaper's javascript code in R. I'm grateful to [@timelyportfolio](https://github.com/timelyportfolio) for wrangling the javascript to the point where it works in V8. He also wrote the [mapshaper htmlwidget](https://github.com/timelyportfolio/mapshaper_htmlwidget), which provides access to the mapshaper web inteface, right in your R session. We have plans to combine the two in the future.

### LICENSE

MIT