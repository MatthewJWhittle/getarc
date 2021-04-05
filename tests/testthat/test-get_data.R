
# Define the endpoints
endpoint_fs = endpoints$ancient_woodland_england
endpoint_ms = endpoints$gb_postcodes

# Get the geometry with get_geojson
query_geom <- utils::modifyList(default_query_parameters(),
                                  list(resultRecordCount = 1, geometryPrecision = 1), keep.null = FALSE)

# Don't get the geometry with get_tibble
query_no_geom <- utils::modifyList(default_query_parameters(),
                                     list(resultRecordCount = 1, returnGeometry = "false"), keep.null = FALSE)

# Map Server
query_url_ms <- paste0(endpoint_ms, "/query")
geom_data_ms <- get_geojson(query_url = query_url_ms,
                            query = query_geom)
no_geom_data_ms <-  get_tibble(query_url = query_url_ms,
                               query = query_no_geom)

# Feature Server
query_url_fs <- paste0(endpoint_fs, "/query")
geom_data_fs <- get_geojson(query_url = query_url_fs,
                            query = query_geom)
no_geom_data_fs <-  get_tibble(query_url = query_url_fs,
                               query = query_no_geom)

testthat::test_that("Getting data works",
                    {
                      # Get geojson returns an sf object
                      expect_equal(class(geom_data_fs), c("sf", "data.frame"))
                      expect_equal(class(geom_data_ms), c("sf", "data.frame"))
                      # Get Tibble returns a tibbble
                      expect_true(tibble::is_tibble(no_geom_data_fs) & tibble::is_tibble(no_geom_data_ms))
                      # Query works by returning one row
                      expect_equal(nrow(geom_data_fs), 1)
                      expect_equal(nrow(geom_data_ms), 1)
                      expect_equal(nrow(no_geom_data_fs), 1)
                      expect_equal(nrow(no_geom_data_ms), 1)
                      expect_error(get_geojson(stringr::str_replace(query_url_fs, "0/query", "0query"), query_no_geom))
                      expect_error(get_tibble(stringr::str_replace(query_url_fs, "0/query", "0query"), query_no_geom))
                    })
