test_that("Feature Server Endpoint", {
  expect_equal(
    feature_server_endpoint(
      host = "https://services.arcgis.com",
      instance = "JJzESW51TqeY9uat",
      feature_server = "Wood_Pasture_and_Parkland",
      layer_id = 0
    ),
    "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0"
  )
})
