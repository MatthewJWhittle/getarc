rm( list = ls())
require(spatialutils)
devtools::load_all()


token <- get_token(use_cache = T)

httr::oauth2.0_token()
token

"https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/GCN_Strategic_Opportunity_Areas_Shropshire/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
"https://ons-inspire.esriuk.com/arcgis/rest/services/Postcodes/ONS_Postcode_Directory_Latest_Centroids/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
"https://<host>/<site>/rest/services/<folder>/<serviceName>/<serviceType>"

# US fires
"https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_MTBS_01/MapServer/66/query?where=1%3D1&outFields=*&outSR=4326&f=json"
