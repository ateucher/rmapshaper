# ms_filter_fields works with polygons

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[102,2],[103,2],[103,3],[102,3],[102,2]]]},\"properties\":{\"a\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[100,0],[101,0],[101,1],[100,1],[100,0]]]},\"properties\":{\"a\":5}}\n]}"]
    }

# ms_filter_fields works with points

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-78.41,-53.95]},\"properties\":{\"x\":-78,\"y\":-53}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[-70.86,65.19]},\"properties\":{\"x\":-71,\"y\":65}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[135.65,63.1]},\"properties\":{\"x\":135,\"y\":65}}\n]}"]
    }

# ms_filter_fields works with lines

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102,2],[102,4],[104,4],[104,2],[102,2]]},\"properties\":{\"a\":1,\"b\":2}}\n]}"]
    }

