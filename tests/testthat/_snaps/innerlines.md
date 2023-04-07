# ms_innerlines works with all classes

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":{\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":{\"rmapshaperid\":3}}\n]}"]
    }

# ms_innerlines works with sys = TRUE

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":{\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":{\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":{\"rmapshaperid\":3}}\n]}"]
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
      "value": ["{\"type\":\"GeometryCollection\", \"geometries\": [\n{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\n{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\n{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\n{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]}\n]}"]
    }

