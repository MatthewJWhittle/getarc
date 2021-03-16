endpoints <-
  list(english_counties = "https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Counties_December_2019_Boundaries_EN_BFC/MapServer/0",
       ancient_woodland_england = "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Ancient_Woodland_England/FeatureServer/0",
       us_fire_occurrence = "https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_MTBS_01/MapServer/62",
       us_burned_areas = "https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_MTBS_01/MapServer/63",
       cairns_corals = "https://services3.arcgis.com/fp1tibNcN9mbExhG/arcgis/rest/services/Cairns_2004_corals/FeatureServer/0",
       gb_wood_pasture_parkland = "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/Wood_Pasture_and_Parkland/FeatureServer/0",
       national_parks_england = "https://services.arcgis.com//JJzESW51TqeY9uat/arcgis/rest/services/National_Parks_England/FeatureServer/0",
       sssi_england = "https://services.arcgis.com//JJzESW51TqeY9uat/arcgis/rest/services/SSSI_England/FeatureServer/0",
       gb_postcodes = "https://ons-inspire.esriuk.com/arcgis/rest/services/Postcodes/ONS_Postcode_Directory_Latest_Centroids/MapServer/0/",
       uk_lpas = "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Planning_Authorities_April_2020_UK_BFE/FeatureServer/0"
       )

usethis::use_data(endpoints, overwrite = TRUE)
