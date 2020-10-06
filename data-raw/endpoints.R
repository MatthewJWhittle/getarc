endpoints <-
  list(english_counties = "https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Counties_December_2019_Boundaries_EN_BFC/MapServer/0")

devtools::use_data(endpoints, overwrite = TRUE)
