# Setup

## Platform

|setting  |value                        |
|:--------|:----------------------------|
|version  |R version 3.4.1 (2017-06-30) |
|system   |x86_64, darwin15.6.0         |
|ui       |RStudio (1.1.298)            |
|language |(EN)                         |
|collate  |en_CA.UTF-8                  |
|tz       |America/Vancouver            |
|date     |2017-07-12                   |

## Packages

|package     |*  |version    |date       |source                         |
|:-----------|:--|:----------|:----------|:------------------------------|
|geojsonio   |   |0.3.2      |2017-02-06 |cran (@0.3.2)                  |
|geojsonlint |   |0.2.0      |2016-11-03 |cran (@0.2.0)                  |
|knitr       |   |1.16       |2017-05-18 |cran (@1.16)                   |
|magrittr    |   |1.5        |2014-11-22 |cran (@1.5)                    |
|readr       |   |1.1.1      |2017-05-16 |cran (@1.1.1)                  |
|rgdal       |   |1.2-8      |2017-07-01 |cran (@1.2-8)                  |
|rgeos       |   |0.3-23     |2017-04-06 |cran (@0.3-23)                 |
|rmapshaper  |   |0.2.0.9000 |2017-07-13 |local (ateucher/rmapshaper@NA) |
|rmarkdown   |   |1.6        |2017-06-15 |cran (@1.6)                    |
|sf          |   |0.4-3      |2017-05-15 |cran (@0.4-3)                  |
|sp          |   |1.2-5      |2017-06-29 |cran (@1.2-5)                  |
|testthat    |   |1.0.2      |2016-04-23 |cran (@1.0.2)                  |
|V8          |   |1.5        |2017-04-25 |cran (@1.5)                    |

# Check results

1 packages with problems

|package  |version | errors| warnings| notes|
|:--------|:-------|------:|--------:|-----:|
|eechidna |1.1     |      0|        1|     1|

## eechidna (1.1)
Maintainer: Ben Marwick <benmarwick@gmail.com>

0 errors | 1 warning  | 1 note 

```
checking re-building of vignette outputs ... WARNING
Error in re-building vignettes:
  ...

    intersect, setdiff, setequal, union


Attaching package: 'purrr'

The following objects are masked from 'package:dplyr':
... 8 lines ...

Attaching package: 'scales'

The following object is masked from 'package:purrr':

    discard

Quitting from lines 155-172 (exploring-election-data.Rmd) 
Error: processing vignette 'exploring-election-data.Rmd' failed with diagnostics:
Value of SET_STRING_ELT() must be a 'CHARSXP' not a 'integer'
Execution halted

checking installed package size ... NOTE
  installed size is  6.3Mb
  sub-directories of 1Mb or more:
    data   4.9Mb
    doc    1.2Mb
```

