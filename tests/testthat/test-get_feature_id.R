endpoint <- "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Special_Protection_Areas_England/FeatureServer/0"
fids <- get_feature_ids(endpoint = endpoint)
fid_query <- get_feature_ids(endpoint = endpoint, query = c(resultRecordCount = 1, where = "Shape__Area < 10000"))
small_feature <- query_layer(endpoint, query = c("where" = paste0("OBJECTID = '", fid_query, "'")))

test_that("get feature ids works", {
  expect_equal(is.vector(fids),
               TRUE)
  expect_equal(length(fids) > 1, TRUE)
  expect_equal(length(fid_query), 1)
  expect_equal(small_feature$Shape__Area < 10000, TRUE)
  expect_equal(nrow(small_feature), 1)
})
