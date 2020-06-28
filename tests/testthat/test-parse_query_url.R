test_that("parse query url", {
  expect_is(
    # Feature Server
    parse_query_url(
      "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
    ),
    class = "function"
  )
  expect_is(
    # Map server
    parse_query_url(
      "https://ons-inspire.esriuk.com/arcgis/rest/services/Postcodes/ONS_Postcode_Directory_Latest_Centroids/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
    ),
    "function"

  )
})
