
# small_feature <-
#   query_layer(endpoints$gb_wood_pasture_parkland,
#               return_n = 100)
#

# Set up ----
# Define the endpoints
endpoint_fs = endpoints$us_fire_occurrence
# Get the geometry with get_geojson
query_geom <-
  query_object(user_query = list(
    resultRecordCount = 2000,
    geometryPrecision = 1,
    outFields = "FIRE_ID"
  ))

query_no_geom <-
  query_object(
    user_query = list(
      resultRecordCount = 2000,
      geometryPrecision = 1,
      outFields = "FIRE_ID",
      returnGeometry = "false"
    )
  )

# Get Data ----
layer_details <- get_layer_details(endpoint_fs)
fire_2000 <-
  get_by_fids(
    endpoint = endpoint_fs,
    query = query_geom,
    return_geometry = TRUE,
    my_token = NULL,
    layer_details = layer_details,
    return_n = query_geom$resultRecordCount,
    out_fields = query_geom$outFields,
    object_ids = NULL
  )

fire_2000_no_geom <-
  get_by_fids(
    endpoint = endpoint_fs,
    query = query_no_geom,
    return_geometry = FALSE,
    my_token = NULL,
    layer_details = layer_details,
    return_n = query_geom$resultRecordCount,
    out_fields = query_geom$outFields,
    object_ids = NULL
  )



test_that("get_by_fids works",
          {
            expect_equal(nrow(fire_2000), 2000)
            expect_s3_class(fire_2000, c("sf", "sfc"))
            expect_s3_class(fire_2000_no_geom, c("tbl"))
          })
