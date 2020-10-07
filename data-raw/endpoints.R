endpoints <-
  list(english_counties = "https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Counties_December_2019_Boundaries_EN_BFC/MapServer/0",
       ancient_woodland_england = "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Ancient_Woodland_England/FeatureServer/0"
       )

usethis::use_data(endpoints, overwrite = TRUE)
