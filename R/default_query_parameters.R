default_query_parameters <-
  function(map_server = FALSE) {
    params <-
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
    if(!map_server){return(params)}
    return(
      modifyList(params, map_server_parameters())
    )

  }
map_server_parameters <- function(){
  list(
    # Te following parameters seem to be essential for map servers (and may be for feature servers)
    geometryType = "esriGeometryEnvelope",
    spatialRel = "esriSpatialRelIntersects",
    #returnGeometry = "true",
    returnTrueCurves = "false",
    returnIdsOnly = "false",
    returnZ = "false",
    returnM = "false",
    returnDistinctValues = "false",
    returnExtentOnly = "false",
    featureEncoding = "esriDefault"
  )
}
