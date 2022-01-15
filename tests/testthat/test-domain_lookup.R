endpoint <-
  "https://services6.arcgis.com/k3kybwIccWQ0A7BB/arcgis/rest/services/Domain_Points/FeatureServer/0"

layer_details <-
  get_layer_details(endpoint = endpoint)

domains <- domain_lookup(layer_details)

test_that("column names will work downstream", {
  expect_equal(colnames(domains), c("field_name", "name", "code"))
  expect_equal(domains$name, c("A", "B", "C", "D", "Zero", "One",  "Two"))
  expect_equal(domains$code, as.character(c(0:3, 0:2)))
  expect_equal(unique(domains$field_name), c("test_domain", "CodedDomain"))
})
