# Append
rm(list = ls())

# Make a dummy dataset
require(tidyverse)
require(devtools)
require(sf)
require(spatialutils)

# https://developers.arcgis.com/rest/services-reference/append-feature-service-layer-.htm

bucks <-
  query_layer(
    endpoint = endpoints$english_counties,
    return_geometry = TRUE,
    query = c(resultRecordCount = 1)
  )

points <- random_points(bbox = st_bbox(bucks),
                        n_points = 10,
                        seed = 1)

points <-
  points %>%
  mutate(id = c(1:10))

points %>% st_write(dsn = "development/points1.geojson")

# I've manually uploaded this to esri

new_points <- random_points(bbox = st_bbox(bucks),
                            n_points = 10,
                            seed = 1) %>%
  mutate(id = c(11:20),
         ObjectId = c(11:20))


# Use a different token for personal account
my_token <- get_token(use_cache = ".patoken")

points_endpoint <-
  "https://services6.arcgis.com/k3kybwIccWQ0A7BB/arcgis/rest/services/Points/FeatureServer/0"
query_layer(endpoint = points_endpoint, my_token = my_token)

# Token works!

details <- get_layer_details(points_endpoint, my_token = my_token)
details$supportsAppend
details$appendUploadFormat

require(geojsonsf)
source <- new_points %>% st_transform(crs = 4326) %>%
  select(id, ObjectId) %>%
  sf_geojson()

details$objectIdField

query <- c(
  f = "json",
  appendUploadFormat = "geojson",
  uploadID = details$serviceItemId,
  upsert = "true",
  fieldMappings='[{"name": "ObjectId", "sourceName": "ObjectId"}, {"name": "id", "sourceName": "id"}]'

)
query_string <- query_string(query = query, my_token = my_token)

query_url <- paste0(endpoint, "/append", query_string)

response <- POST(query_url, body = list(source = source))

content <- response %>% content() %>% fromJSON()

GET(
  paste0(content$statusUrl, query_string(query = NULL, my_token = my_token))
) %>% content(as = "parsed") %>% fromJSON()


query_layer(endpoint = points_endpoint, my_token = my_token)
