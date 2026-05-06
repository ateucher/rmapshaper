## Existing CRAN check issues

1. I fixed the `ERROR` in the vignette:

! could not find function "%>%"

An imported package which previously exported `%>%` no longer does. I replaced
it with `|>` and added R >= 4.1 to Depends in the DESCRIPTION file.

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## Downstream dependencies

I checked 15 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * I saw 0 new problems
 * I failed to check 0 packages.
