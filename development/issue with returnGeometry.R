devtools::load_all()
cumbria <- query_layer(
  endpoint = endpoints$english_counties,
  query = c(where = "cty19nm LIKE 'Cumbria'"), crs = 4326
)

# # returns records
# cumbria_ancient_woodlands <-
#   query_layer(endpoint = endpoints$ancient_woodland_england,
#               bounding_box = sf::st_bbox(cumbria))
#
# # returns no records
# cumbria_ancient_woodlands <-
#   query_layer(endpoint = endpoints$ancient_woodland_england,
#               bounding_box = sf::st_bbox(cumbria),
#               query = c(returnGeometry = "false"))

# Warnings:
# 49: In CPL_read_ogr(dsn, layer, query, as.character(options),  ... :
#                       GDAL Error 1: Invalid Feature object. Missing 'geometry' member.


endpoint = endpoints$ancient_woodland_england
bounding_box = sf::st_bbox(cumbria)
# query = c(returnGeometry = "false")
query = NULL
crs = 4326
my_token = NULL
return_geometry = FALSE



    # It would be useful to add a line of code in here to check and auto refresh the token
    # Get the details of the layer to
    layer_details <- get_layer_details(endpoint = endpoint, my_token = my_token)

    # If a bounding box has been specified then generate the spatial query and combine with the query parameters
    if (!is.null(bounding_box)) {
      query <- c(query, spatial_query_to_list(bbox = bounding_box))
    }

    argument_parameters <- c(returnGeometry = lower_logical(return_geometry))

    # Add query parameters which have been set as arguments in the function
    query <- modify_named_vector(query, argument_parameters)
    # Add in the default parameters but only where they are not present in query
    query <- modify_named_vector(default_query_parameters(), query)

    feature_ids <- get_feature_ids(endpoint = endpoint, query = query, my_token = my_token)

    if(length(feature_ids$objectIds) < 1){
      warning("No data matching query, returning an empty tibble")
      return(tibble::tibble())
    }

    # Generate the query string
    query_string <- query_string(query = query, my_token = my_token)
    query_url <- paste0(endpoint, "/query", query_string)


    if (return_geometry) {
      data <- get_geojson(query_url = query_url)
    } else{
      data <- get_tibble(query_url = query_url)
    }


    # Parse the variables -----
    # This should probably be wrapped up into one parsing function at some point
    data <-
      parse_coded_domains(data,
                          domain_lookup(layer_details))

    data <- parse_datetimes(data = data,
                            feature_details = layer_details)

    # If the specified crs is not 4326 (the current crs) then transform the data
    # This might be redundant as we can specify the outcrs when requesting the data
    if (crs != 4326 & return_geometry) {
      data <- data %>% sf::st_transform(crs = crs)
    }

    # Warn if the number of rows in the data is
    if(nrow(data) == layer_details$maxRecordCount){
      warning("May have reached limit of maximum features to return, try performing query to narrow down results.")
    }

    return(data)

