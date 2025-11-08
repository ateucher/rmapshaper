The file `mapshaper-browserify.min.js` is generated from the `mapshaper` node module (see `LICENSE` file) using the `browserify` node module, as suggested in the [V8 vignette](https://cran.r-project.org/web/packages/V8/vignettes/npm.html).

The license for `mapshaper` and its dependencies are listed in `node_packages.csv`.

## Steps to Update Bundled Mapshaper

### 1. Install required npm packages

```bash
npm install -g browserify uglify-js
npm install mapshaper
```

Note: The modules to include in the `browserify` call can be found in the mapshaper package.json dependencies: https://github.com/mbloch/mapshaper/blob/master/package.json

### 2. Generate the browserified bundle

```bash
echo "global.mapshaper = require('mapshaper');" > in.js
browserify -r sync-request -r mproj -r buffer -r iconv-lite -r fs -r flatbush -r rw -r path -r kdbush -r @tmcw/togeojson -r @placemarkio/tokml -r idb-keyval in.js -o inst/mapshaper/mapshaper-browserify.js
rm in.js
```

### 3. Apply V8 compatibility modifications

To make this work in V8, which does not have all of the capability of Node, three modifications are required to `inst/mapshaper/mapshaper-browserify.js`:

**Note:** Line numbers will vary with each mapshaper version. Use grep/search to locate the functions.

#### 3a. Fix setTimeout and setImmediate in reduceAsync

Because `setTimeout` and `setImmediate` are not available in the V8 engine, the `reduceAsync` function must be modified.

Search for: `function reduceAsync(arr, memo, iter, done)`

In the current version (0.6.113), this is around line 5120.

Thanks to [@timelyportfolio](https://github.com/timelyportfolio) for figuring this out:

```javascript
function reduceAsync(arr, memo, iter, done) {
  // For V8 in R: commented out the next line which looks for setTimeout / setImmediate
  //var call = typeof setImmediate == 'undefined' ? setTimeout : setImmediate;
  var i=0;
  next(null, memo);

  function next(err, memo) {
    // Detach next operation from call stack to prevent overflow
    // Don't use setTimeout(, 0) if setImmediate is available
    // (setTimeout() can introduce a long delay if previous operation was slow,
    //    as of Node 0.10.32 -- a bug?)
    if (err) {
      return done(err, null);
    }
    // For V8 in R: comment out the `call` call, and replace with anonymous function
    /*
    call(function() {
      if (i < arr.length === false) {
        done(null, memo);
      } else {
        iter(memo, arr[i++], next);
      }
    }, 0);
    */
    (function() {
      if (i < arr.length === false) {
        done(null, memo);
      } else {
        iter(memo, arr[i++], next);
      }
    })();
  }
}
```

#### 3b. Change output format from buffer to geojson

In the `exportGeoJSON` function, the output format must be changed from `'buffer'` to `'geojson'`.

Search for: `function exportGeoJSON(dataset, opts)`

Then find the line: `content: exportDatasetAsGeoJSON(d, opts, 'buffer')`

In the current version (0.6.113), this is around line 23213.

Change it to:

```javascript
content: exportDatasetAsGeoJSON(d, opts, 'geojson'),
```

#### 3c. Disable printStartupMessages

The `printStartupMessages()` call throws errors in V8 and must be commented out.

Search for: `printStartupMessages()`

In the current version (0.6.113), this is around line 51837.

Comment out the call:

```javascript
// For V8 in R: Commented out to avoid errors
//if (!runningInBrowser()) {
//  printStartupMessages();
//}
```

### 4. Minify the bundle

Minify (uglify) the javascript to make it smaller and faster:

```bash
cd inst/mapshaper
uglifyjs mapshaper-browserify.js -o mapshaper-browserify.min.js -b beautify=false,ascii_only=true
rm mapshaper-browserify.js
```

**Note:** The `ascii_only=true` option is necessary to make it run on Windows.

### 5. Update the version in R code

The mapshaper version is not programmatically accessible from the bundled JavaScript (as of version 0.6.113), so it must be manually updated in `R/utils.R` in the `bundled_ms_version()` function.

Find the current version:
```bash
npm list mapshaper
```

Then update the version string in `R/utils.R`:
```r
bundled_ms_version <- function() {
  # ms <- ms_make_ctx()
  # ms$get("mapshaper.internal.VERSION")
  "0.6.113"  # Update this version number
}
```
 