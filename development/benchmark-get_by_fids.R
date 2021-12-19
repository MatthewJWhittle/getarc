devtools::load_all()



# Set up ----
# Define the endpoints
endpoint_fs = endpoints$us_fire_occurrence
# Get the geometry with get_geojson
query_geom <- query_object(user_query = list(resultRecordCount = 5000,
                                             geometryPrecision = 1,
                                             returnGeometry = "false"))

layer_details <- get_layer_details(endpoint_fs)

#
microbenchmark::microbenchmark(

  get_by_fids(
    endpoint = endpoint_fs,
    query = query_geom,
    return_geometry = FALSE,
    my_token = NULL,
    layer_details = layer_details,
    return_n = NULL,
    object_ids = NULL
  ), times = 10
)
