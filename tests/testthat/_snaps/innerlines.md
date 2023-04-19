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
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":null},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":null},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":null},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":null}\n]}"]
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
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":null},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":null},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":null},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":null}\n]}"]
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

