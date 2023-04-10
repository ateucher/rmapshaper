# rmapshaper 0.5.0

This is a fairly major release with much of the internal plumbing changed. I have tried to keep user-facing changes to a minimum, but please report any issues to https://github.com/ateucher/rmapshaper/issues.

* Switched to using the `geojsonsf` package instead of `geojsonio` for object conversion (#118).
* Updated the bundled mapshaper version to `v0.6.25` (#130).
* Dropped support for `geojson_list` objects. This was a rarely-used class from the `geojsonio` package (#118).
* Arguments `force_FC`, `sys`, and `sys_mem` are now passed to `apply_mapshaper_commands` via `...` rather than explicitly, so they are now documented in the `...` section of each function. This may break some existing code if you were passing values to these arguments by position rather than by name, especially using `force_FC` in `ms_simplify` as it was not at the end of the argument list. It may also change the class of the return value for some input classes and functions (such as `ms_lines` and `ms_innerlines`) as `force_FC` will inherit the default `TRUE` for all functions.
* Added `quiet` argument to silence mapshaper console messages when using `sys = TRUE`. This can be controlled globally with `options("mapshaper.sys_quiet" = TRUE)` (#125).
* Added ability to globally set the system memory when using the system mapshaper via `options("mapshaper.sys_mem"=X)`, where `X` is the amount of memory in GB.

# rmapshaper 0.4.6

* Fixed a long-standing issue where `units` columns in `sf` objects would cause failures; all numeric columns of class `"units"` are now converted to numeric before running through mapshaper commands. (#116, thanks @Robinlovelace)
* Added a default value for `force_FC` in `apply_mapshaper_commands()`. The default value is `TRUE` (#120, thanks @dblodgett-usgs)
* Documentation fix in `check_sys_mapshaper()` - fixed description of return value (#117, thanks @dblodgett-usgs).
* Included an example of setting memory allocation when using the system mapshaper in README (#114, thanks @baldeagle).

# rmapshaper 0.4.5

* Fixed a bug where functions would fail when there was a space in user's `tmpdir()`
path and `sys = TRUE` (#107)
* Updated bundled mapshaper library to v 0.4.163, which fixed a bug in `ms_erase` (#110, #104, #112)
* When `sys = TRUE`, now uses `mapshaper-xl` in the system call, allowing 
larger memory use. Default 8GB can be specified in new argument `sys_mem` (#94, #112)
* Internally switched to using `system2()` over `system()` for flexibility

# rmapshaper 0.4.4

* Small fixes for compatibility with sf >= 0.9

# rmapshaper 0.4.3

* Add checks, a package startup message, and helpful errors for the case when 
  a user has an old version of `libv8` installed, as they do not support many
  aspects of modern JavaScript (ES6). This appears to only impact `ms_erase()`
  and `ms_clip()`.
* Using `apply_mapshaper_commands()` no longer deletes a file when used on a local file (#99, #100)

# rmapshaper 0.4.2

* Added `rgdal` to `Suggests` so `ms_clip` and `ms_erase` can transform
 `Spatial*` objects when they have different CRSs.
* When an input `sf` object is a tibble, the output is now now also a tibble, 
(#95, thanks @mdsumner)
* Upgraded to `mapshaper` v0.4.107
* Bumped minimum version of V8 to 3.0

# rmapshaper 0.4.1

* Fixed a bug when using `sys = TRUE` would fail on Windows in some circumstances (#77)
* Fixed an issue where running `rmapshaper` functions on `sfc` objects failed with 
`sf v0.7`

# rmapshaper 0.4.0

## New features

* Added `sys` argument to allow the use of the system `mapshaper` if it's installed (#61)

## Improvements and bug fixes

* Upgraded to `mapshaper` v0.4.64 (#60)
* `sf::st_read()` is now used throughout for reading from disk and from geojson 
strings, which allows for greater consistency and better performance.
* Better handling of different column classes (#68, thanks @mdsumner)
* Avoid stackoverflow caused by adding special geojson classes (#71,
https://github.com/ropensci/geojsonio/issues/128)
* The name of the sf column is now properly retained (#70)
* Fixed issue where encoding/special characters were not preserved (#67)

# rmapshaper 0.3.1

* Fixed a bug where converting geojson objects to sf failed with sf >= 0.5-6 (#64)

# rmapshaper 0.3.0

* Methods for sf and sfc classes have been added (#46)
* `rmapshaperid` column is only retained if it is the only column, otherwise it's dropped.
* `ms_innerlines` returns only the geometry for `sf` and `Spatial*DataFrame` classes. (#57)
* `ms_dissolve` gains a `weight` argument for generating weighted centroids of dissolved points. (#39) 

# rmapshaper 0.2.0

* Added `snap_interval` to `ms_simplify()` (#43, @nikolai-b)
* Bug-fix: Respect `drop_null_geometries` argument in `ms_simplify.geo_list()` (#45, @nikolai-b)
* Add Kent Russell (@timelyportfolio) to authors list for his JavaScript expertise and advice
* Add Matthew Bloch (@mbloch) to authors list as mapshaper copyright holder
* Update mapshaper to version 0.3.41
* A V8 session is now launched once per function call and destroyed when the function exits, rather than created on package load and retained for the entire session (#49)
* Column classes are now restored after being sent through mapshaper functions (#46)
* Fixed a bug where very small values of `keep` in `ms_simplify()` were converted to scientific notation (#48)
* Added `weighting` argument to `ms_simplify()` (#27)
* Added `remove_slivers` argument in `ms_clip()` and `ms_erase()`

# rmapshaper 0.1.0

* Initial release



