pasture_endpoint <-
  "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0"


pasture_server_details <-
  get_feature_server_details(pasture_endpoint)

test_that("multiplication works", {
  expect_equal(class(pasture_server_details),
               "list",
               label = "returns list")
  expect_equal(length(pasture_server_details) > 1,
               TRUE,
               label = "returns list length > 1")
})
