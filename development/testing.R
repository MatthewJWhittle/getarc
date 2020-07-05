rm( list = ls())
require(spatialutils)
devtools::load_all()
bbox <- xy_to_points()  %>% st_buffer(10000) %>% st_transform(crs = 4326) %>% st_bbox()


endpoint <- feature_server_endpoint(
  host = "https://services.arcgis.com",
  instance = "JJzESW51TqeY9uat",
  feature_server = "Wood_Pasture_and_Parkland",
  layer_id = 0
)

feature_details <-
  get_layer_details(
  endpoint = endpoint
)

query <- c(
  returnIdsOnly = "false",
  # Get all features with sql query 1 = 1
  where = "1=1",
  outFields = "*",
  returnCountOnly = "false",
  f = "json",
  token = NULL,
  # Assert that the data is lat lon if writing to geojson
  outSR = 4326
)
spatial <- spatial_query_to_list(bbox)

query <- c(query, spatial)

get_feature_ids <-
  function(endpoint, query = NULL, my_token = NULL){

    parameters <- names(query)
    query <-
      c(query[parameters != "returnIdsOnly"], returnIdsOnly = "true")

    # Check that a where clause was passed to query, if not add where 1=1 to return all features
    if(!("where" %in% parameters)){
      query <- c("where" = "1=1", query)
    }

    query_string <- query_string(query = query,  my_token = my_token)

    query_url <- paste0(endpoint, "/query", query_string)

    response <- GET(query_url)

    stopifnot(response$status_code == 200)

    response_content <- fromJSON(content(response))

    response_content$objectIds
  }

fids <- get_feature_ids(endpoint = endpoint)


feature_details$maxRecordCount

pasture <-
  query_layer_fs(host = "https://services.arcgis.com",
                instance = "JJzESW51TqeY9uat",
                feature_server = "Wood_Pasture_and_Parkland",
                layer_id = 0,
                query = c(resultRecordCount = 1))

pasture


endpoint <-
  feature_server_endpoint(
  host = "https://services.arcgis.com",
  instance = "JJzESW51TqeY9uat",
  feature_server = "Wood_Pasture_and_Parkland",
  layer_id = 0
)

spatial <- spatial_query_to_list(bbox)

response <-
  paste0(endpoint,
         "/query",
         query_string(returnIdsOnly = "true", where = "1=1", spatial = spatial)) %>%
  GET()


feature_details <- content(response, as = "parsed") %>% fromJSON()


length(feature_details$objectIds)



object_ids <- response %>% content() %>% fromJSON()



"https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/GCN_Strategic_Opportunity_Areas_Shropshire/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
"https://ons-inspire.esriuk.com/arcgis/rest/services/Postcodes/ONS_Postcode_Directory_Latest_Centroids/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
"https://<host>/<site>/rest/services/<folder>/<serviceName>/<serviceType>"

# US fires
"https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_MTBS_01/MapServer/66/query?where=1%3D1&outFields=*&outSR=4326&f=json"
