# Investigation: Why `-proj EPSG:3005 init=EPSG:4326` Returns Empty Response

## Problem

The command `apply_mapshaper_commands(geo, "-proj EPSG:3005 init=EPSG:4326")` returns an empty response with a warning.

## Root Cause

The bundled `mproj` library (v0.0.40) **does not support EPSG code lookups**. It only accepts full PROJ.4 definition strings.

### Technical Details

1. **mproj Library**: The package uses `mproj@0.0.40` bundled in the browserified JavaScript
2. **No EPSG Database**: Unlike modern PROJ (v6+), `mproj` is a lightweight port of PROJ.4 v4.9.3 that does **not** include EPSG code definitions
3. **Error Handling**: When an invalid projection string is passed:
   - mapshaper/mproj fails to parse it
   - The V8 callback logs the error to `console.error` (not visible in R)
   - Returns `null`/`undefined` data
   - R's `class_geo_json()` function detects this and returns an empty response with the warning: "The command returned an empty response. Please check your inputs"

## Test Results

Tested 8 different formats:

| Format | Works? | Example |
|--------|--------|---------|
| `EPSG:3005 init=EPSG:4326` | ✗ | EPSG codes not recognized |
| `epsg:3005 init=epsg:4326` | ✗ | Lowercase doesn't help |
| `+init=epsg:3005 from=+init=epsg:4326` | ✗ | Traditional PROJ.4 init syntax not supported |
| `+init=epsg:3005` | ✗ | Still tries EPSG lookup |
| `EPSG:3005` | ✗ | Same issue |
| **Full PROJ.4 string** | **✓** | **This is the only working method** |
| `crs=epsg:3005` | ✗ | Alternative syntax doesn't work |
| `crs=EPSG:3005` | ✗ | Case doesn't matter |

## Solution

**Use full PROJ.4 definition strings instead of EPSG codes:**

```r
# WGS84 (EPSG:4326) to BC Albers (EPSG:3005)
apply_mapshaper_commands(
  geo,
  "-proj '+proj=aea +lat_0=45 +lon_0=-126 +lat_1=50 +lat_2=58.5 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs'"
)
```

### Getting PROJ.4 Strings from EPSG Codes

If you need to convert EPSG codes to PROJ.4 strings in R:

```r
library(sf)

# Get PROJ.4 string for EPSG:3005
st_crs(3005)$proj4string
# Returns: "+proj=aea +lat_0=45 +lon_0=-126 +lat_1=50 +lat_2=58.5 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs"
```

## Why This Happens

1. Modern `mapshaper` (command-line version with Node.js) has access to the full PROJ database
2. The bundled V8/browser version uses `mproj`, a minimal JavaScript port
3. `mproj` intentionally excludes the large EPSG definition database to keep file size small
4. This makes EPSG codes unsupported in `rmapshaper` when using the bundled JavaScript (`sys = FALSE`)

## Workaround Options

### Option 1: Use Full PROJ.4 Strings (Works Now)

```r
apply_mapshaper_commands(geo, "-proj '<full PROJ.4 string>'")
```

### Option 2: Use System mapshaper (if installed)

If you have mapshaper installed via npm, use `sys = TRUE`:

```r
# System mapshaper has full PROJ support
apply_mapshaper_commands(geo, "-proj EPSG:3005 init=EPSG:4326", sys = TRUE)
```

### Option 3: Helper Function (Recommended)

Create a helper that converts EPSG codes to PROJ.4 strings:

```r
epsg_to_proj4 <- function(epsg_code) {
  sf::st_crs(epsg_code)$proj4string
}

# Usage:
target_crs <- epsg_to_proj4(3005)
apply_mapshaper_commands(geo, paste0("-proj '", target_crs, "'"))
```

## Recommendation for Package

Consider adding:
1. Documentation warning about EPSG code support
2. A wrapper function that auto-converts EPSG codes to PROJ.4 strings
3. Or recommend users install system mapshaper for projection operations

## Test Script

See `test_proj_formats.R` for the full test suite demonstrating all format attempts.
