test_that("get_layer_details returns a list", {
  expect_equal(class(
    get_layer_details(endpoint = "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0")
  ),
  "list")
})
