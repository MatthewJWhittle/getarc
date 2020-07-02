endpoint <-
  "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0"
one_row <- query_layer(endpoint = endpoint,
                       query = c(resultRecordCount = 1))
one_row_bng <- query_layer(
  endpoint = endpoint,
  crs = 27700,
  query = c(resultRecordCount = 1)
)

small_feature <-
  query_layer(endpoint,
              query = c("where" = "Shape__Area < 30", resultRecordCount = 1))


ten_rows <- query_layer(endpoint = endpoint,
                        query = c(resultRecordCount = 10))

sql_query <- query_layer(
  endpoint = endpoint,
  query = c(resultRecordCount = 1,
            where = "SUBTYPE = 'Parkland' AND INTERPQUAL = 'Medium'")
)
# Perform a spatial query
bbox <-
  st_bbox(c(
    xmin = -1.310819,
    ymin = 51.369722,
    xmax = -1.307946,
    ymax = 51.371520
  ),
  crs = 4326)

spatial_query <-
  query_layer(endpoint = endpoint,
              bounding_box = bbox)

test_that("query layer works", {
  # Check that resultRecordCount = 1 works
  expect_equal(nrow(one_row),
               1)
  # Check that the function returns a data frame
  expect_equal(class(one_row),
               c("sf", "data.frame"))
  # Test that it transforms data when the crs != 4326
  expect_equal(st_crs(one_row_bng)$epsg,
               27700)
  # Check that sql  where query works
  expect_equal(sql_query$SUBTYPE, "Parkland")
  expect_equal(sql_query$INTERPQUAL, "Medium")
  # Did the spatial query only return one result?
  expect_equal(nrow(spatial_query),
               1)
  expect_warning(query_layer(endpoint = endpoint, query = c(where = "1 = 2")))
  # Does the area query have the desired result
  expect_equal(small_feature$Shape__Area < 30, TRUE)

})
