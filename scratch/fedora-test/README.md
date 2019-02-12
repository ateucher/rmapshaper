
This is to test and try to debug
[\#76](https://github.com/ateucher/rmapshaper/issues/76), where
inconsistent results are returned when using the internal mapshaper via
`V8` vs using the system mapshaper by setting `sys =
TRUE`.

## Local Test:

``` r
poly <- "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"properties\":{\"foo\":\"bar\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[1745493.1964,6001802.1687],[1733165.0316,5989714.0167],[1709110.421,5986671.9829],[1701512.1629,5996204.8743],[1694071.9249,5996670.1668],[1698472.8948,5988332.4659],[1688395.3701,5989681.2008],[1677965.6958,6005588.9233],[1662101.242,6027765.2897],[1633099.9635,6066188.0936],[1632333.2593,6068917.4647],[1611887.8264,6107105.9235],[1615313.2862,6111814.5646],[1615273.0793,6122910.9659],[1607401.5736,6138887.1603],[1586362.9653,6168009.0013],[1580992.292,6187484.7528],[1598604.2695,6179319.1659],[1602302.8684,6165378.966],[1610993.2613,6147279.1175],[1618217.2473,6141247.7304],[1619611.4661,6131232.4434],[1626312.6186,6125451.5999],[1631049.39,6131536.119],[1635581.8515,6132044.6677],[1639612.9348,6128430.5315],[1648872.4808,6126997.4738],[1651390.585,6135510.2472],[1658793.6184,6130516.4984],[1664017.9086,6132002.6554],[1667504.0425,6122580.5619],[1684932.9873,6121315.2794],[1687775.4183,6113350.8992],[1698221.3987,6096136.1567],[1702333.8303,6093768.139],[1721686.2959,6084337.3811],[1733658.2241,6064257.0177],[1736021.5816,6054847.8425],[1734255.2674,6038727.4396],[1728574.9872,6038982.8492],[1731745.7286,6024545.9745],[1736045.2861,6011617.8379],[1745493.1964,6001802.1687]]]}}]}"

ctx <- V8::v8()
ctx$source(system.file("mapshaper/mapshaper-browserify.min.js",
                       package = "rmapshaper"))
```

    ## [1] "function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require==\"function\"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error(\"Cannot find module '\"+o+\"'\");throw f.code=\"MODULE_NOT_FOUND\",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}"

``` r
ctx$assign("poly", poly)
ctx$eval("var return_data;")
ctx$eval("mapshaper.applyCommands(\"-simplify 0.05\", poly, function(Error, data) {
  if (Error) console.error('Error in V8 context: ' + Error.stack);
  return_data = data;
})")

ret_v8 <- ctx$get("return_data")

writeChar(poly, "poly.geojson")

system("mapshaper poly.geojson -simplify 0.05 -o poly_simp.geojson")
ret_sys <- readChar("poly_simp.geojson", nchars = 5000)

cat("original:")
```

    ## original:

``` r
print(nchar(poly))
```

    ## [1] 1330

``` r
cat("sys-false: ")
```

    ## sys-false:

``` r
print(nchar(ret_v8))
```

    ## [1] 279

``` r
cat("sys-true: ")
```

    ## sys-true:

``` r
print(nchar(ret_sys))
```

    ## [1] 279

``` r
all.equal(ret_v8, ret_sys)
```

    ## [1] TRUE

## The issue on Fedora

Build the Fedora image from the [Dockerfile](Dockerfile) and run the
test script (above) to test the behaviour on Fedora:

``` bash
docker build -t fedr .
```

    ## Sending build context to Docker daemon  25.94MB
    
    
    ## Step 1/10 : FROM rhub/fedora-gcc:latest
    ##  ---> 3a6abffe734d
    ## Step 2/10 : RUN yum install -y v8-devel
    ##  ---> Using cache
    ##  ---> 21cb883c16e8
    ## Step 3/10 : RUN dnf install -y   gdal-devel   proj-devel   proj-epsg   proj-nad   geos-devel   udunits2-devel   R
    ##  ---> Using cache
    ##  ---> f8871e80a890
    ## Step 4/10 : RUN dnf install -y   protobuf-devel   protobuf-compiler   jq-devel   libcurl-devel   openssl-devel   nodejs
    ##  ---> Using cache
    ##  ---> b93d0052e9cb
    ## Step 5/10 : RUN npm install -g mapshaper
    ##  ---> Using cache
    ##  ---> 27e6682e5189
    ## Step 6/10 : RUN echo "options(repos = c(CRAN = \"https://cran.rstudio.com/\"))" >> /usr/lib64/R/etc/Rprofile.site
    ##  ---> Using cache
    ##  ---> 5185210bd740
    ## Step 7/10 : RUN R -e "install.packages(\"udunits2\",configure.args=\"--with-udunits2-include=/usr/include/udunits2/\")"
    ##  ---> Using cache
    ##  ---> 10213324ed8d
    ## Step 8/10 : RUN R -e "install.packages(c(\"rmapshaper\", \"randgeo\"))"
    ##  ---> Using cache
    ##  ---> 4d7e9475474c
    ## Step 9/10 : RUN curl -LO https://github.com/ateucher/rmapshaper/files/1911058/statsnzregional-council-2018-clipped-generalised-GPKG.zip &&   unzip statsnzregional-council-2018-clipped-generalised-GPKG.zip *.gpkg
    ##  ---> Using cache
    ##  ---> 569da5509e2d
    ## Step 10/10 : COPY test.R /test.R
    ##  ---> Using cache
    ##  ---> 4c4752ca376f
    ## Successfully built 4c4752ca376f
    ## Successfully tagged fedr:latest

``` bash
docker run fedr Rscript test.R
```

    ## [1] "function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require==\"function\"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error(\"Cannot find module '\"+o+\"'\");throw f.code=\"MODULE_NOT_FOUND\",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}"
    ## [o] Wrote poly_simp.geojson
    ## original:[1] 1330
    ## sys-false: [1] 279
    ## sys-true: [1] 279
    ## [1] TRUE

Enter the running container to try to debug:

``` bash
$ docker run -it fedr sh
```
