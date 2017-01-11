The file `mapshaper-browserify.js` is generated from the `mapshaper` node module (see `LICENSE` file) using the `browserify` node module, as suggested in the [V8 vignette](https://cran.r-project.org/web/packages/V8/vignettes/npm.html):


The license for `mapshaper` and its dependencies, as well as their licenses, are listed in `node_packages.csv`.

```
npm install -g browserify
npm install mapshaper
echo "global.mapshaper = require('mapshaper');" > in.js
browserify in.js -o inst/mapshaper/mapshaper-browserify.js
rm in.js
```

### setTimout and setImmediate
Because the functions `setTimeout` and `setImmediate` are not available in the V8 engine, the  definition of `utils.reduceAsync` (approximately line `18000` in the browserified file) must be slightly modified to avoid them. Thanks to [@timelyportfolio](https://github.com/timelyportfolio) for figuring this out:

```javascript
utils.reduceAsync = function(arr, memo, iter, done) {
  // For V8 in R: commented out the next line wich looks for setTimeout / setImmediate
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
};
```
