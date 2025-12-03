## Existing CRAN check issues

1. I fixed the `NOTE`:

	```
	checkRd: (-1) ms_simplify.Rd:36: Lost braces
		36 | \url{https://github.com/mbloch/mapshaper/wiki/Simplification-Tips}{link}
	```
	- I switched to `\href{}` instead of `\url{}`.

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## Downstream dependencies

I checked 17 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * I saw 0 new problems
 * I failed to check 0 packages.
