This release fixes CRAN check errors on Solaris (https://www.r-project.org/nosvn/R.check/r-patched-solaris-x86/rmapshaper-00check.html), due to it having an old version of the system library libv8 (required by R package V8). The presence of an old version of libv8 impacts two functions in rmapshaper. This version of rmapshaper checks for the installed version of libv8 and gives a helpful startup message to users, causes affected functions to fail gracefully, and conditions the running of tests, examples, and vignette code on the system libv8 version.

## Test environments

* local macOS install (Mojave 10.14.6), R 3.6.2
* Ubuntu 16.04 LTS (on Travis-CI: R-release, R-devel, and R-oldrel)
* Ubuntu 18.04 LTS (On GitHub Actions, checking with both old and modern libv8)
* Windows Server 2012 R2 x64 (on AppVeyor: R 3.6.2 Patched (2020-01-13 r77666))
* win-builder (R-devel)

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## Downstream dependencies

I checked 8 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * I saw 0 new problems
 * I failed to check 0 packages
