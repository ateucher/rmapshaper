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



