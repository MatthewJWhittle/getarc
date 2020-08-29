endpoint <-
  "https://services.arcgis.com//JJzESW51TqeY9uat/arcgis/rest/services/National_Parks_England/FeatureServer/0"

layer_details <-
  get_layer_details(endpoint = endpoint)

domains <- domain_lookup(layer_details)

test_that("column names will work downstream", {
  expect_equal(colnames(domains), c("field_name", "name", "code"))
})
