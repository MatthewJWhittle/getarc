data <-
  query_layer_ms(
    host = "https://ons-inspire.esriuk.com/",
    instance = "arcgis",
    folder = "Postcodes",
    service_name = "ONS_Postcode_Directory_Latest_Centroids",
    layer_id = 0,
    query = c(resultRecordCount = 1)
  )

test_that("Query Map Server Layer", {
  # Returned one row
  expect_equal(nrow(data), 1)
  expect_equal(class(data), c("sf", "data.frame"))
})
