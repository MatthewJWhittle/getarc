# Error:  Error: Argument 'txt' must be a JSON string, URL or file.
devtools::load_all()
query_layer(endpoints$ancient_woodland_england,
            return_geometry = TRUE,
            query = c(resultRecordCount = 2))
#
# query_layer(endpoints$sssi_england,
#             return_geometry = FALSE)

endpoint = endpoints$ancient_woodland_england
in_geometry = NULL
spatial_filter = "intersects"
return_geometry = FALSE
query = NULL#  = c(where = "")
crs = 4326
my_token = NULL
bounding_box = lifecycle::deprecated()
# query_layer <-
#   function(endpoint,
#            in_geometry = NULL,
#            spatial_filter = "intersects",
#            return_geometry = TRUE,
#            query = NULL,
#            crs = 4326,
#            my_token = NULL,
#            bounding_box = lifecycle::deprecated()
#   ) {
    # Check depreciated arguments ----------
    # Check if user has supplied `baz` instead of `bar`
    if (lifecycle::is_present(bounding_box)) {
      # Signal the deprecation to the user
      deprecate_warn("0.0.0.9500", "query_layer(bounding_box = )", "query_layer(geometry = )")
      # Deal with the deprecated argument for compatibility
      in_geometry <- bounding_box
    }

    # Check that a valid token has been passed in
    stopifnot(is.null(my_token) || c("Token") %in% class(my_token))

    #https://developers.arcgis.com/rest/services-reference/layer-feature-service-.htm


    # It would be useful to add a line of code in here to check and auto refresh the token
    # Get the details of the layer to
    layer_details <- get_layer_details(endpoint = endpoint, my_token = my_token)

    # If an in_geometry has been specified then generate the spatial query and combine with the query parameters
    if (!is.null(in_geometry)) {
      query <- utils::modifyList(query, spatial_query(in_geometry,
                                                        spatial_filter = esri_spatial_filter(spatial_filter),
                                                        max_char = 1000), keep.null = FALSE)
    }

    argument_parameters <- c(returnGeometry = lower_logical(return_geometry))

    # Add query parameters which have been set as arguments in the function
    query <- utils::modifyList(query, argument_parameters, keep.null = FALSE)
    # Add in the default parameters but only where they are not present in query
    query <- utils::modifyList(default_query_parameters(), query, keep.null = FALSE)

    count <- get_count(endpoint = endpoint, query = query, my_token = my_token)

    if(count < 1){
      warning("No data matching query, returning an empty tibble")
      return(tibble::tibble())
    }

    # Generate the query string
    query_string <- query_string(query = query, my_token = my_token)

    query_url <- paste0(endpoint, "/query", query_string)
    # This behaviour is undesirable when queries become more complex.
    # Need to find a way of making the query string available to users
    # message(paste0("Requesting data:\n", query_url))

    # When a returnGeometry = "false" query was used previously
    # get_geojson wouldn't parse the data correctly and would return an empty tibble
    # A new function get_tibble has been added to use a different method for requesting and parsing data
    # when the geometry isn't returned.
    if (return_geometry || map_server(endpoint)) {
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
      warning("May have reached maxRecordCount.")
    }
    if(nrow(data) == 0){
      warning("No data returned by query.")
    }
    return(data)
  #}
