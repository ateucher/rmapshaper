## Test environments
* local OS X install (Sierra 10.12.6), R 3.4.2
* Ubuntu 14.04.5 LTS (on Travis-CI: R-release, R-devel, and R-oldrel)
* Windows Server 2012 R2 x64 (on AppVeyor: R-release (3.4.2))
* win-builder (R-devel)
* Windows Server 2008 R2 SP1, R-release, 32/64 bit (on r-hub)
* macOS 10.11 El Capitan, R-release (on r-hub)

## R CMD check results
There were no ERRORs, WARNINGs, or NOTEs.  
On Ubuntu on r-hub the 'sf' package was not available for checking. However 
'sf' was available in all other test environments and there were no problems.

## Downstream dependencies
I have run R CMD check on all downstream dependencies of rmapshaper (https://github.com/ateucher/rmapshaper/tree/master/revdep). There were no
problems found.
