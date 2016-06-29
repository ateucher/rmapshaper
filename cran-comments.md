## Resubmission
This is a resubmission. In this version I have removed three tests that were failing on computers with GDAL 2.1.0 installed, due to a known bug in that version of GDAL (GDAL bug report: https://trac.osgeo.org/gdal/ticket/6538).

## Test environments
* local OS X install, R 3.3.1 (GDAL 2.2.0dev)
* ubuntu 12.04 (on travis-ci with GDAL 1.10.0), R 3.3.1 (devel, release, and old-rel)
* win-builder (devel and release)
* ubuntu 16.04, R 3.3.1 with GDAL 2.1.0

## R CMD check results

There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* This is a new submission.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.
