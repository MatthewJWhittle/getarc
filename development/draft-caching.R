devtools::load_all()
debugonce(query_layer)

query_layer <-
  function(endpoint,
           in_geometry = NULL,
           spatial_filter = "intersects",
           return_geometry = TRUE,
           where = NULL,
           out_fields = c("*"),
           return_n = NULL,
           geometry_precision = NULL,
           query = NULL,
           crs = 4326,
           my_token = NULL,
           cache = NULL) {
    #https://developers.arcgis.com/rest/services-reference/layer-feature-service-.htm
    # It would be useful to add a line of code in here to check and auto refresh the token
    # Get the details of the layer to

    argument_parameters <-
      c(
        returnGeometry = lower_logical(return_geometry),
        outFields = paste0(out_fields, collapse = ","),
        resultRecordCount = return_n,
        geometryPrecision = geometry_precision,
        where = where
      )
    # argument_parameters[is.null(argument_parameters)]

    layer_details <-
      get_layer_details(endpoint = endpoint, my_token = my_token)

    cache_object <-
      init_cache(
        endpoint = endpoint,
        query = query,
        cache = cache,
        layer_details = layer_details
      )
    if(!cache_object$any_changes){return(cache_object$data_cache)}

    # Get the unique ID field from the layer details.
    id_field <-
      get_unique_id_field(endpoint = endpoint, layer_details = layer_details)



    # If an in_geometry has been specified then generate the spatial query and combine with the query parameters
    if (!is.null(in_geometry)) {
      cache_object$query <- utils::modifyList(cache_object$query,
                                   spatial_query(x = in_geometry,
                                                 spatial_filter = esri_spatial_filter(spatial_filter)),
                                                 keep.null = FALSE)
    }

    # Add query parameters which have been set as arguments in the function
    cache_object$query <- utils::modifyList(cache_object$query,
                                              argument_parameters,
                                              keep.null = FALSE)

    # Add in the default parameters but only where they are not present in query
    cache_object$query <- utils::modifyList(default_query_parameters(), cache_object$query, keep.null = FALSE)


    # Get the data by feature IDs allowing us to exceed the max record count
    data <-
      get_by_fids(endpoint,
                  query = cache_object$query,
                  my_token,
                  return_geometry,
                  return_n,
                  layer_details,
                  out_fields)

    ####
    # Parse the variables -----
    # This should probably be wrapped up into one parsing function at some point
    data <-
      parse_coded_domains(data,
                          domain_lookup(layer_details))

    data <- parse_datetimes(data = data,
                            feature_details = layer_details)

    # If the specified crs is not 4326 (the current crs) then transform the data
    # This might be redundant as we can specify the outcrs when requesting the data
    if (crs != 4326 &
        return_geometry & any(c("sf", "sfc") %in% class(data))) {
      data <- data %>% sf::st_transform(crs = crs)
    }

    # Print a warning if the query didn't return any data
    if (nrow(data) == 0) {
      warning("No data returned by query.")
    }
    data <- refresh_cache(data, cache_object)
    return(data)

  }


refresh_cache <-
  function(data, cache_object){
    if (!cache_object$use_cache) {return(data)}


    # Write Cache
    if (!cache_object$cache_exists) {
      sf::st_write(data,
                   cache_object$cache_path,
                   delete_dsn = TRUE,
                   quiet = TRUE)
      return(data)
    }

    new_data_ids <- dplyr::pull(data, id_field)
    cache_data_ids <- dplyr::pull(cache_object$data_cache, id_field)


    data_refreshed <-
      dplyr::bind_rows(
        # Remove anything from the cache that has been updated
        dplyr::filter(cache_object$data_cache, !cache_data_ids %in% new_data_ids),
        data
        )
    sf::st_write(data_refreshed,
                 cache_object$cache_path,
                 delete_dsn = TRUE,
                 quiet = TRUE)
    return(data_refreshed)
  }

init_cache <-
  function(endpoint, query, cache, layer_details, my_token) {

    cache_object <- init_cache_object(query = query,
                                      use_cache = !is.null(cache),
                                      cache = cache)

    if(!cache_object$use_cache){return(cache_object)}

    # Caching ------
    # Should a cache be used? A cache should be used if the user has supplied a path, and the layer supports
    # edit tracking
    cache_object$method <- cache_method(layer_details)

    if (is.null(cache_object$method) & cache_object$use_cache) {
      warning("This layer doesn't support edit tracking so cannot be cached")
      # Return an empty cache object if the layer doesn't support any for of edit tracking
      return(cache_object)
    }

    cache_object$cache_exists <- file.exists(cache)
    # Fail quickly if the cache directory doesn't exist
    stopifnot(dir.exists(dirname(cache)))

    if(!cache_object$cache_exists){
      return(cache_object)
    }


    last_layer_edit <-
      parse_esri_datetime(layer_details$editingInfo$lastEditDate)

    # Load cache
    if (cache_object$cache_exists) {
      cached_time <- file.info(cache)$ctime
      # Print a message to make it clear which cache is being loaded & when it is from
      message(glue::glue("Loading cached data ({cached_time}) from: '{cache}'"))
      # Conver the Cache time to UTC as this is what is accepted by esri api
      cached_time <- lubridate::with_tz(cached_time, tzone = "UTC")
      cache_object$data_cache <- sf::st_read(cache, quiet = TRUE)
      cache_object$any_changes <- last_layer_edit > cached_time

      # If there haven't been any edits since the data was last cached or the
      # the method is using layer edits then return the object
      if (!cache_object$any_changes | cache_object$method == "layer_edit") {
        return(cache_object)
      }

      # Edits Query
      # Otherwise generate an edits query
      # Generate the edits query from the field records the edit times and the last download time
      # Between the time the data is downloaded and written to file, there will be  gap where some edits are missed
      # I need a way of recording the actual dl time in the file
      edits_query <-
        glue::glue(
          "{layer_details$editFieldsInfo$editDateField} > '{as.character(cached_time)}'"
        )

      # If a where query hasn't been passed in, then use the edits query. If not combine them
      if (is.null(where)) {
        where <- edits_query
      } else{
        where <- glue::glue("({where}) AND {edits_query}")
      }
    }

    cache_object$query <- utils::modifyList(cache_object$query, c(where = where), keep.null = FALSE)

    return(cache_object)
  }

init_cache_object <-
  function(data_cache = NULL,
           request_fids = NULL,
           query = NULL,
           method = NULL,
           any_changes = FALSE,
           use_cache = FALSE,
           cache_path = NULL) {
    return(
      list(
        data_cache = data_cache,
        request_fids = request_fids,
        query = query,
        method = method,
        any_changes = any_changes,
        use_cache = use_cache,
        cache_path = cache_path
      )
    )
  }
