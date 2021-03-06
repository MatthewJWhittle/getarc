# Define the endpoints for the tests
no_dates_endpoint <-
  "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/GCN_eDNA_Pond_Surveys_for_DLL_England/FeatureServer/0"
dates_endpoint <-
  "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/GCN_Class_Survey_Licence_Returns_England/FeatureServer/0"

# Need to add an endpoint for a mapserver with properly formatted dates
# there is some logic in the function that behaves differently if passed a mapserver endpoint
# Dates to parse
dates_details <-
  get_layer_details(dates_endpoint)
dates <-
  get_geojson(paste0(dates_endpoint, "/query"),
    query = c(resultRecordCount = 10, default_query_parameters())
  )

# Contains no dates
no_dates_details <-
  get_layer_details(no_dates_endpoint)
no_dates <-
  get_geojson(paste0(no_dates_endpoint, "/query"),
    query = c(resultRecordCount = 10, default_query_parameters())
  )


test_that("datetimes parse", {
  expect_equal(info = "returns datetime",
               class(parse_datetimes(dates, dates_details)$Survey_Dat),
               c("POSIXct", "POSIXt"))
  expect_equal(info = "No missing values",
               any(is.na(
                 parse_datetimes(dates, dates_details)$Survey_Dat
               )),
               FALSE)
  expect_equal(info = "returns an sf object when no date variabes are present",
               class(parse_datetimes(no_dates, no_dates_details)),
               c("sf", "data.frame"))
  # Check that if the date column is not present in the data (due to a outFields query)
  # Then the function doesn't throw an error
  expect_error(info = "doesn't error when datetime col not present",
               parse_datetimes(data = dates[colnames(dates) != "Survey_Dat"], feature_details = dates_details),
               NA)
  expect_equal(info = "returns the input data untouched when no datetime cols present",
               parse_datetimes(data = dates[colnames(dates) != "Survey_Dat"], feature_details = dates_details),
               dates[colnames(dates) != "Survey_Dat"])

})
