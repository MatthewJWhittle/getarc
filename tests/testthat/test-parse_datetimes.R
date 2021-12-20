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
           get_by_fids(
             endpoint = dates_endpoint,
             query = query_object(user_query = list(resultRecordCount = 10)),
             return_n = 10,
             my_token = NULL,
             layer_details = dates_details,
             out_fields = "*",
             return_geometry = TRUE,
             object_ids = NULL
           )

# Contains no dates
no_dates_details <-
  get_layer_details(no_dates_endpoint)
no_dates <-
  get_by_fids(
    endpoint = no_dates_endpoint,
    query = query_object(user_query = list(resultRecordCount = 10)),
    return_n = 10,
    return_geometry = TRUE,
    my_token = NULL,
    layer_details = no_dates_details,
    out_fields = "*",
    object_ids = NULL
  )


# Get the datetime fields
date_fields <- detect_dttm_fields(dates, dates_details)

# Parse dates
dates_parsed <- parse_datetimes(dates, dates_details)

# Convert TZs
convert_to_tz <- "Europe/Amsterdam"
tz_converted <- convert_tz(dates_parsed, tz = convert_to_tz,
                           dttm_fields = date_fields)$Survey_Dat

test_that("datetimes parse", {
  expect_equal(
    info = "Detects DTTM Field",
    date_fields, "Survey_Dat"
  )
  expect_equal(info = "returns datetime",
               class(dates_parsed$Survey_Dat),
               c("POSIXct", "POSIXt"))
  expect_equal(info = "No missing values",
               any(is.na(
                 dates_parsed$Survey_Dat
               )),
               FALSE)
  expect_equal(
    info = "Timezones convert",
    lubridate::tz(tz_converted),  convert_to_tz
  )
  expect_equal(info = "returns an sf object when no date variabes are present",
               class(parse_datetimes(no_dates, no_dates_details)),
               c("sf", "data.frame"))
  # Check that if the date column is not present in the data (due to a outFields query)
  # Then the function doesn't throw an error
  expect_error(info = "doesn't error when datetime col not present",
               parse_datetimes(data = dates[colnames(dates) != "Survey_Dat"], layer_details = dates_details),
               NA)
  expect_equal(info = "returns the input data untouched when no datetime cols present",
               parse_datetimes(data = dates[colnames(dates) != "Survey_Dat"], layer_details = dates_details),
               dates[colnames(dates) != "Survey_Dat"])
  expect_error(query_layer(endpoints$us_fire_occurrence, return_n = 100), NA)

})
