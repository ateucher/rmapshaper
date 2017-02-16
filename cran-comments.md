## Test environments
* local OS X install (Sierra 10.12.3), R 3.3.2
* Ubuntu 14.04 (on Travis-CI: devel, release (3.3.2), and old-rel)
* Fedora Linux, R-devel, GCC (on r-hub)
* Windows Server 2008 R2 SP1, R 3.3.2, 32/64 bit (on r-hub)
* win-builder (R-devel)

## R CMD check results
There were no ERRORs, or WARNINGs.

There was one NOTE:
License components with restrictions and base license permitting such:
  MIT + file LICENSE
File 'LICENSE':
  YEAR: 2016
  COPYRIGHT HOLDER: Andy Teucher

## Downstream dependencies
I have run R CMD check on downstream dependencies of rmapshaper. There were no
issues.

-------

This version includes fixes to tests that were failing due to changes in dependency 'geojsonio'.

Thanks!
Andy Teucher