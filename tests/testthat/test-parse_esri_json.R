

# Set up ----
return_n = 100
in_parts = 10
geometry = TRUE


# Getting the inputs for the function ---------
# Define the endpoints

# Define a function to get the data for testing
get_json_list <-
  function(endpoint, return_n, in_parts, geometry, out_fields) {
    layer_details <- get_layer_details(endpoint)

    # Sample some field names to return only part & speed up the processs
    fields <- field_names(layer_details)
    stopifnot(out_fields %in% fields)


    # Get the geometry with get_geojson
    query <-
      query_object(
        user_query = list(
          resultRecordCount = return_n,
          geometryPrecision = 1,
          outFields = paste(out_fields, collapse = ","),
          returnGeometry = geometry
        )
      )

    # This function works by checking if the requested return count is less tha the max record count.
    # If so, it doesnn't bother with getting the FIDs and just requests the data and returns it.
    # Getting FIDs is a big overhea so this should be avoided where possible.
    query_url <- paste0(endpoint, "/query")

    # Otherwise, get the FIDs and return the data
    # The FIDs are used for two things: first to determine if any results will be returned by a query;
    # second to get the data by FIDs
    object_ids <-
      get_feature_ids(endpoint = endpoint,
                      query = query)



    # Then split the vector so it doesn't exceed the max record count

    object_ids_split <-
      split_vector(x = object_ids$objectIds,
                   max_length = round(length(object_ids$objectIds) / in_parts))

    querys <-
      purrr::map(object_ids_split,
                 ~ utils::modifyList(
                   query,
                   where_in_query(object_ids$objectIdFieldName, .x, named = TRUE)
                 ),
                 keep.null = FALSE)


    # Download the data for each query
    purrr::map(
      querys,
      ~ get_data(
        query_url = query_url,
        query = .x,
        return_geometry = geometry,
        my_token = NULL,
        pb = NULL
      )
    )
  }



basic_parse <-
  function(json_list){
    map(json_list,
        ~sf::st_read(.x, quiet = TRUE, stringsAsFactors = FALSE)) %>% bind_rows()
  }



json_list_geom_point <-
  get_json_list(endpoint = endpoints$us_fire_occurrence, out_fields = c("FIRE_ID", "MODERATE_THRESHOLD"),
                return_n = 100, in_parts = 10, geometry = TRUE)

json_list_no_geom <-
  get_json_list(endpoint = endpoints$us_fire_occurrence, out_fields = c("FIRE_ID", "MODERATE_THRESHOLD"),
                return_n = 100, in_parts = 10, geometry = FALSE)

json_list_geom_polygon <-
  get_json_list(endpoint = endpoints$ancient_woodland_england, out_fields = c("NAME", "THEMNAME"),
                return_n = 100, in_parts = 10, geometry = TRUE)

json_list_1l <- get_json_list(endpoint = endpoints$ancient_woodland_england,
                              out_fields = c("NAME", "THEMNAME"),
                              return_n = 10, in_parts = 1, geometry = TRUE)


# Benchmarking ----
# # Uncomment to benchmark
# microbenchmark::microbenchmark(
#   basic_parse(json_list_geom_point),
#   parse_esri_json(json_list_geom_point, geometry = TRUE), times = 30
# )
#
# microbenchmark::microbenchmark(
#   basic_parse(json_list_geom_polygon),
#   parse_esri_json(json_list_geom_polygon, geometry = TRUE), times = 30
# )
#
#
# microbenchmark::microbenchmark(
#   basic_parse(json_list_no_geom),
#   parse_esri_json(json_list_no_geom, geometry = FALSE), times = 30
# )
#
# microbenchmark::microbenchmark(
#   basic_parse(json_list_1l),
#   parse_esri_json(json_list_1l, geometry = TRUE), times = 30
# )

# Tests ---------
points <- parse_esri_json(json_list_geom_point, geometry = TRUE)
table <- parse_esri_json(json_list_no_geom, geometry = FALSE)
polygon <- parse_esri_json(json_list_geom_polygon, geometry = TRUE)
length_1 <- parse_esri_json(json_list_1l, geometry = TRUE)

test_that("Parsing JSON works",
          {
            expect_s3_class(points,
                            class = c("sf", "sfc"))
            expect_s3_class(length_1,
                            class = c("sf", "sfc"))
            expect_s3_class(table,
                            class = "tbl")
            expect_s3_class(polygon,
                            class = c("sf", "sfc"))
            expect_equal(purrr::map_dbl(.x = list(points, table, polygon), nrow),
                         rep(x = 100, times = 3))
            expect_equal(nrow(length_1), 10)

          })

# NULL Values ----

# The API returns NULL values and these were not being converted to NA properly
# This tests against an endpoint where there are known null values
# The number of rows in the tibble should match the count
ep_null_values <- "https://services6.arcgis.com/k3kybwIccWQ0A7BB/arcgis/rest/services/NULL_Values_Test/FeatureServer/0"


null_json <- get_data(query_url = paste0(ep_null_values, "/query?"),
                 return_geometry = FALSE,
                 query = query_object(user_query = list(returnGeometry = "false", outFields = "null_values")), my_token = NULL, pb = NULL)

null_count <- get_count(endpoint = ep_null_values)

test_that("Null values parse as NA",
          {
            expect_equal(
              nrow(parse_json_table(null_json)), 3
            )
          }
          )
