layer_details <-
  get_layer_details(endpoint = "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0")

test_that("get_layer_details returns a list", {
  expect_equal(class(layer_details),
               "list")
  expect_false(is.null(layer_details$maxRecordCount))
})
