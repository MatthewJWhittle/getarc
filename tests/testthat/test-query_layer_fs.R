data <-
  query_layer_fs(host = "https://services.arcgis.com",
                 instance = "JJzESW51TqeY9uat",
                 feature_server = "Wood_Pasture_and_Parkland",
                 layer_id = 0,
                 query = c(resultRecordCount = 1))

test_that("Query Feature Layer", {
  # Returned one row
  expect_equal(nrow(data), 1)
  expect_equal(class(data), c("sf", "data.frame"))
})
