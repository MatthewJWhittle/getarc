# AddFeatures
devtools::load_all()

rm(list = ls())
require(tidyverse)
require(sf)
# Use a different token for personal account
my_token <- get_token(use_cache = ".patoken")

points_endpoint <-
  "https://services6.arcgis.com/k3kybwIccWQ0A7BB/arcgis/rest/services/Points/FeatureServer/0"
query_layer(endpoint = points_endpoint, my_token = my_token)



features <-
'[
  {
    "geometry" : {"x" : -7.56226, "y" : 49.76757},
    "attributes" : {
      "id" : 11,
      "ObjectId" : 11
    }
  }
  ]'

response <-
  POST(url = glue::glue("{points_endpoint}/addFeatures"),
     body = list(token = parse_access_token(my_token),
                 f = "json",
                 features = features
                 ))


response %>% content()


query_layer(endpoint = points_endpoint, my_token = my_token) %>% view()

features_sf <-
  tibble::tibble(x = c(500200, 500202, 502400), y = c(844074, 834074, 834073), id = c(21, 20, 15), objectId = c(15, 2, 30)) %>%
  sf::st_as_sf(coords = c("x", "y"), crs = 27700)


features_sf
id_field <- "ObjectId"

# ids <-
#   query_layer(endpoint = points_endpoint, return_geometry = FALSE, out_fields = id_field,
#             my_token = my_token)

fids <-
  get_feature_ids(endpoint = points_endpoint,
                my_token = my_token)

new_features_sf <- features_sf %>% filter(!objectId %in% fids$objectIds)

# Then convert it to JSON

epsg = st_crs(new_features_sf)$epsg
# new_features_sf$geometry %>% sf_to_json()


new_features_sf %>%
  mutate(geom_json = geometry_to_json(geometry[1]))
purrr::transpose(new_features_sf) %>%
  map()


geojsonsf::sf_geojson(new_features_sf) %>%
  jsonlite::prettify()



new_features_sf$geometry %>% sf::st_as_text()

response <-
  POST(url = glue::glue("{points_endpoint}/addFeatures"),
       body = list(token = parse_access_token(my_token),
                   f = "json",
                   features = geojsonsf::sf_geojson(new_features_sf %>% st_transform(crs = 27700))
       ))


response %>% content()

