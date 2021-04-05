default_query_parameters <-
  function() {
    list(
      returnIdsOnly = "false",
      # Get all features with sql query 1 = 1
      where = "1=1",
      outFields = "*",
      returnCountOnly = "false",
      f = "json",
      token = NULL,
      # Assert that the data is lat lon if writing to geojson
      outSR = 4326
    )
  }
