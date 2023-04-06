# ms_lines works with all classes

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":3}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102,2],[102,3],[103,3]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":4}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":5}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,1],[102,1],[102,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":6}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[104,1],[103,1]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":7}}\n]}"]
    }

# ms_lines works with fields specified

    {
      "type": "character",
      "attributes": {
        "class": {
          "type": "character",
          "attributes": {},
          "value": ["geojson", "json"]
        }
      },
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"RANK\":2,\"TYPE\":\"inner\",\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":{\"RANK\":2,\"TYPE\":\"inner\",\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"foo\",\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"foo\",\"rmapshaperid\":3}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102,2],[102,3],[103,3]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":4}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":5}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,1],[102,1],[102,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":6}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[104,1],[103,1]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":7}}\n]}"]
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
      "value": ["{\"type\":\"FeatureCollection\", \"features\": [\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[103,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":0}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[102,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":1}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[103,2]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":2}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,2],[103,1]]},\"properties\":{\"RANK\":1,\"TYPE\":\"inner\",\"rmapshaperid\":3}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[102,2],[102,3],[103,3]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":4}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,3],[104,3],[104,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":5}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[103,1],[102,1],[102,2]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":6}},\n{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[104,2],[104,1],[103,1]]},\"properties\":{\"RANK\":0,\"TYPE\":\"outer\",\"rmapshaperid\":7}}\n]}"]
    }

