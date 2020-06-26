# Specify the URL for SSSIs
url <- "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/SSSI_England/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
# Parse the url into a get function
get_sssi <- parse_query_url(url)
# Get the data, passing an additional parameter to only return one feature
one_sssi <- get_sssi(query = c("resultRecordCount" = "1"))


expect_equal(class(one_sssi),
             c("sf", "data.frame"))

expect_equal(nrow(one_sssi),
             1)
