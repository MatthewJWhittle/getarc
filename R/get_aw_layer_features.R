

get_aw_layer_features <-
  function(feature_server_name, layer_name, layer_id = 0, my_token, crs = 4326){
    #https://developers.arcgis.com/rest/services-reference/layer-feature-service-.htm

    host <- "https://services9.arcgis.com"
    instance <- "eNX73FDxjlKFtCtH/ArcGIS"
    rest <- "rest"
    services <- "services"
    server_type <- "FeatureServer"
    request_type <- "query"

    endpoint <-
      list(host,
           instance,
           rest,
           services,
           feature_server_name,
           server_type,
           layer_id,
           request_type) %>% paste0(collapse = "/")



    f <- "json"
    # "where=FID>=0" was causing a 400 error
    # This where clause is taken from the natural england arc gis api example
    where <- "1=1"

    # Get the token from the supplied acceess token
    token <- parse_access_token(my_token)



    # Build a list of query parameters
    query <- list(f = f,
                  token = token,
                  # Get all features with sql query 1 = 1
                  where = where,
                  # Assert that the data is lat lon if writing to geojson
                  outSR = 4326,
                  returnIdsOnly = "false",
                  outFields = "*",
                  returnCountOnly = "false")


    # Collapse the parameters into a string of length 1
    query_string <- collapse_query_parameters(query)

    # Create a temporary file for caching the spatial data
    temp_file <- tempfile(fileext = ".geojson")
    # Request the spatial data and write it to a temporary file as JSON
    request <- paste0(endpoint, "?", query_string) %>%
      httr::GET(write_disk(temp_file, overwrite = T))
    # Fail on error
    stopifnot(status_code(request) == 200)
    # Read the data from the temporary file
    data <- st_read(temp_file, stringsAsFactors = FALSE)
    # If the specified crs is not 4326 (the current crs) then transform the data
    if(crs != 4326){
      data <- data %>% st_transform(crs = crs)
    }
    return(data)
  }

