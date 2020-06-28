test_that("Map Server Endpoint", {
  expect_equal(
    map_server_endpoint(
      host = "https://ons-inspire.esriuk.com",
      instance = "arcgis",
      folder = "Postcodes",
      service_name = "ONS_Postcode_Directory_Latest_Centroids",
      layer_id = 0
    ),
    "https://ons-inspire.esriuk.com/arcgis/rest/services/Postcodes/ONS_Postcode_Directory_Latest_Centroids/MapServer/0/"
  )
})
