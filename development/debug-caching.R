devtools::load_all()

require(sf)
# Test Caching behaviour
# First clear the old cache
cache_file <- "development/data-cache/test-dttm.geojson"
if(file.exists(cache_file)) {file.remove(cache_file)}
if(!dir.exists(dirname(cache_file))) {dir.create(dirname(cache_file), recursive = TRUE)}
# define the layer to cache and where to cache it
ep_test_points <- "https://services6.arcgis.com/k3kybwIccWQ0A7BB/arcgis/rest/services/Caching_Points_Datetime/FeatureServer/0"
# Download the points layer and cache it
points_dl <- query_layer(endpoint = ep_test_points,
                         cache = cache_file)
# read the cached data
cached_data <- sf::st_read(cache_file, stringsAsFactors = FALSE)
# Add a new point to the layer to the retreive when updating the cache
add_point_to_test_ep(endpoint = ep_test_points, attributes = list(a_string = sample(letters, size =  1), dttm = lubridate::date_decimal(decimal = rnorm(mean = 2021, sd = 0.1, n =1))))
# Retrieve the updated layer without caching so the results can be compared
updated_layer <- query_layer(endpoint = ep_test_points)
updated_cache <- query_layer(endpoint = ep_test_points,
                             cache = cache_file)
# Check the file on disk
updated_cache_file <- sf::st_read(cache_file, stringsAsFactors = FALSE)

tibble(
  cache_file = updated_cache_file$CreationDate,
  layer = updated_layer$CreationDate,
  cache = updated_cache$CreationDate
)


lubridate::with_tz(head(updated_cache_file$CreationDate), tzone = "UTC") == head(updated_layer$CreationDate)
as.numeric(lubridate::with_tz(head(updated_cache_file$CreationDate), tzone = "UTC"))
as.numeric(head(updated_layer$CreationDate))
