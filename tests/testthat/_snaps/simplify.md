# ms_simplify.geojson and character works with defaults

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-7.1549869,45.4449053],[-9.6292336,41.0325088],[-6.3787009,28.8026166],[1.8629117,35.5400723],[-7.344442,37.6863061],[-7.1549869,45.4449053]]]},\"properties\":{\"rmapshaperid\":0}}\n]}"]
    }

# ms_simplify.geojson works with different methods

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-7.1549869,45.4449053],[-6.3787009,28.8026166],[1.8629117,35.5400723],[-7.1549869,45.4449053]]]},\"properties\":{\"rmapshaperid\":0}}\n]}"]
    }

---

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-7.1549869,45.4449053],[-17.6800154,33.0680873],[-6.3787009,28.8026166],[-7.1549869,45.4449053]]]},\"properties\":{\"rmapshaperid\":0}}\n]}"]
    }

# exploding works with geojson

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[103,2],[103,3],[102,3],[102,2]]]},\"properties\":{\"rmapshaperid\":0}}\n]}"]
    }

---

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[103,2],[103,3],[102,3],[102,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[101,0],[101,1],[100,1],[100,0]]]},\"properties\":{\"rmapshaperid\":1}}\n]}"]
    }

# ms_simplify works with drop_null_geometries

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-152.3433185,-51.1400329],[-168.2902719,-61.7109737],[-153.3221574,-65.1360902],[-142.1320457,-59.7694693],[-152.3433185,-51.1400329]]]},\"properties\":{\"rmapshaperid\":0}}\n]}"]
    }

---

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[-152.3433185,-51.1400329],[-168.2902719,-61.7109737],[-153.3221574,-65.1360902],[-142.1320457,-59.7694693],[-152.3433185,-51.1400329]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":null,\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":null,\"properties\":{\"rmapshaperid\":2}}\n]}"]
    }

# ms_simplify works with lines

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[-146.030845,-17.697398],[-147.696223,-21.1162469],[-156.2250727,-21.2045764],[-150.6399109,-15.4286993],[-146.030845,-17.697398]]},\"properties\":{\"rmapshaperid\":0}}\n]}"]
    }

# ms_simplify works correctly when all geometries are dropped

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"GeometryCollection\", \"geometries\": [\n\n]}"]
    }

# snap_interval works

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[102,2],[103,2],[103,3],[101,3],[101,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[101,1],[103,1],[103,2],[102,1.9],[101,2]]]},\"properties\":{\"rmapshaperid\":1}}\n]}"]
    }

---

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[102,2],[103,2],[103,3],[101,3],[101,2]]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[101,2],[101,1],[103,1],[103,2],[102,2],[101,2]]]},\"properties\":{\"rmapshaperid\":1}}\n]}"]
    }

