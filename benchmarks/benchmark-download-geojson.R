
dl_json <-
  function() {
    query_url <-
      "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0/query"
    query <-
      list(
        returnIdsOnly = "false",
        where = "1=1",
        outFields = "*",
        returnCountOnly = "false",
        f = "json",
        outSR = 4326,
        returnGeometry = "true",
        resultRecordCount = 100
      )
    httr::POST(url = query_url, body = query)
  }
dl_geojson <-
  function() {
    query_url <-
      "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0/query"
    query <-
      list(
        returnIdsOnly = "false",
        where = "1=1",
        outFields = "*",
        returnCountOnly = "false",
        f = "GeoJSON",
        outSR = 4326,
        returnGeometry = "true",
        resultRecordCount = 100
      )
    httr::POST(url = query_url, body = query)
  }

microbenchmark::microbenchmark(dl_json(),
                               dl_geojson(), times = 20)
