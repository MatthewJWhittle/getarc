#' Set Cache Directory
#'
#' Set the directory to be used when caching layers
#'
#' @param directory the directory to use when caching
#' @export set_cache_directory
set_cache_directory <- function(directory, create = FALSE){
  exists <- dir.exists(directory)
  # If the directory doesn't already exist & the user wants to create it then create it
  if(create & !exists){dir.create(path = directory, recursive = TRUE)}
  # If it doesn't exist and the user hasn't specified to create it the fail with an error
  if(!create & !exists){stop(message("Directory doesn't exist, set create = TRUE to create it"))}

  # edit the config
  edit_config(changes = list(getarc_cache_directory = directory))
}
#' Cache Directory
#'
#' Get the getarc caching directory from the environment
#'
#' @return a string defining the caching directory
#' @export cache_dir
cache_dir <- function(){
  directory <- Sys.getenv("getarc_cache_directory")
  if(directory == ""){stop(message("No default cache directory set, use set_cache_directory() to set it."))}
  return(directory)
}
#' Clear Layer Cache
#'
#' Clear the cache for a specific endpoint
#'
#' This function deletes cache files which relate to an endpoint
#' @param endpoint the endpoint for the layer to remove the cache
#' @return NULL
#' @export clear_layer_cache
clear_layer_cache <-
  function(endpoint){
    path <- construct_cache_path(endpoint = endpoint, create_dir = FALSE)
    file.remove(path)
  }
#' Empty the cache
#'
#' Remove all caching files
#'
#' This function removes all caching files used by getarc
#' @param force should the function bypass asking for user confirmation to proceed? default is to ask for confirmation (FALSE)
#' @return NULL
#' @export empty_cache
empty_cache <-
  function(force = FALSE){
    if(!force){
      continue <- ask_user("Are you sure you want to empty the cache, this action is not reversible?")
      if(!continue){return(NULL)}
    }
    cache_files <- list.files(cache_dir(), recursive = TRUE, full.names = TRUE)
    # If there are no files to delete then don't run
    if(length(cache_files) == 0){return(NULL)}
    # Otherwise delete them
    for(file in cache_files){
      file.remove(file)
    }
  }
#' Ask User
#'
#' Ask a user a prompt
#'
#' This function asks a user a prompt and then parses the response to TRUE/FALSE. It will fail if the user doesn't respond with y/n
#' @param prompt a string defining the prompt to ask the user
#' @return TRUE or FALSE depending user input
ask_user <-
  function(prompt){
    answer <- readline(prompt = paste(prompt, "y/n"))
    # Check response is correct
    stopifnot(answer %in% c("y", "n"))
    # return a logical value
    return(answer == "y")
  }
#' Construct Cache Path
#'
#' Construct a path based upon the service url
#'
#' This function takes a service url and a cache directory and creates a path that is unique to the service url
#' @param endpoint the endpoint or service url of the layer
#' @param cache_dir the caching directory to be used (usually project specific)
#' @return a string defining the cache path
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_remove
construct_cache_path <-
  function(endpoint, create_dir = TRUE){
    path <- stringr::str_remove_all(endpoint, "https://")
    path <- stringr::str_replace_all(path, "\\.", "_")
    path <- stringr::str_remove_all(path, "rest/services/")
    cache_dir <- cache_dir()
    cache_dir <- stringr::str_remove(cache_dir, "/$")
    cache_path <- paste0(cache_dir, "/", path, "-getarc-cache.geojson")

    # If the directory doesn't exist and the user want the function to create it then do that
    if(!dir.exists(dirname(cache_path)) & create_dir){
      dir.create(dirname(cache_path), recursive = TRUE)
    }

    return(cache_path)
  }

#' Init Cache Object
#'
#' Initialise the cache object
#' @param data_cache the cached data
#' @param object_ids the object ids to request
#' @param query_object_ids the object IDs which should actually be returned (with their attributes & features)
#' @param query the query to execute
#' @param method the caching method to use
#' @param any_changes Have there been any changes to the data since the last cache?
#' @param cache_path where is/should the data be saved
#' @param id_field which is the unique id field
#' @param use_cache should a cache be used? This is interpreted from whether the user
#' passes in a cache path
#' @return a cache_object
init_cache_object <-
  function(data_cache = NULL,
           object_ids = NULL,
           query_object_ids = NULL,
           query = NULL,
           method = NULL,
           any_changes = TRUE,
           use_cache = FALSE,
           cache_path = NULL,
           id_field = NULL) {
    return(
      list(
        data_cache = data_cache,
        object_ids = object_ids,
        query = query,
        method = method,
        any_changes = any_changes,
        use_cache = use_cache,
        cache_path = cache_path,
        id_field = id_field
      )
    )
  }
#' Init Cache
#'
#' Initialise the cache
#'
#' @param endpoint the endpoint against which to query
#' @param query the query to execute
#' @param cache either: the cache path supplied by the user; a value of TRUE for using automatic cache path (based on endpoint) or NULL for no caching
#' @param layer_details the layer details argument supplied by get layer details
#' @param id_field the id field against which to renew the cache
#' @param my_token the authentication token returned by get_token or other oauth method
#' @return a cache object defining the cached data & various bits of info to determine how the cache should be updated if at all
#' @importFrom dplyr any_of
#' @importFrom dplyr select
#' @importFrom glue glue
#' @importFrom geojsonsf geojson_sf
#' @importFrom lubridate with_tz
init_cache <-
  function(endpoint,
           query,
           cache,
           layer_details,
           my_token = NULL,
           id_field) {

    # First check if the user has specified default caching
    if(!is.null(cache) && is.logical(cache) && cache == TRUE){
    # If they have then convert the logical value to a cache path based on the endpoint & default cache dir
      cache <- construct_cache_path(endpoint = endpoint, create_dir = TRUE)
      }
    cache_object <- init_cache_object(query = query,
                                      use_cache = !is.null(cache),
                                      cache_path = cache,
                                      id_field = id_field)

    # Get the object IDs returned by the query (not just those that have changed)
    # This allows us to check if all are in the cache and then get the extras as required
    # This is neccessary in a scenario where the cache was initially generated based upon a
    # restricted query and then used to return data for a query that returns FIDs not in the cache
    # The function will check what the query needs, what the cache contains and what has changed.
    # It will return the object IDs which need to be downloaded
    cache_object$query_object_ids <-
      get_feature_ids(endpoint = endpoint,
                      query = cache_object$query,
                      my_token = my_token)

    # If a cache isn't being used, the put the query object IDs (those which should be
    # returned by the user query - even if part from a cache) into the object IDs (those
    # which are actually requested from the API)
    if(!cache_object$use_cache){
      cache_object$object_ids <- cache_object$query_object_ids
      return(cache_object)
      }

    # Should a cache be used? A cache should be used if the user has supplied a path, and the layer supports
    # edit tracking
    cache_object$method <- cache_method(layer_details)
    cache_object$cache_exists <- file.exists(cache_object$cache_path)

    if (is.null(cache_object$method) & cache_object$use_cache) {
      warning("This layer doesn't support edit tracking so cannot be cached")
      # Return an empty cache object if the layer doesn't support any for of edit tracking
      # Change use cache to FALSE
      cache_object$use_cache <- FALSE
      return(cache_object)
    }

    # Fail quickly if the cache directory doesn't exist
    stopifnot(dir.exists(dirname(cache_object$cache_path)))

    if(!cache_object$cache_exists){
      return(cache_object)
    }


    last_layer_edit <-
      parse_esri_datetime(layer_details$editingInfo$lastEditDate, tz = layer_timezone(layer_details))

    # Load cache
    if (cache_object$cache_exists) {
      cached_time <- file.info(cache_object$cache_path)$ctime
      # Print a message to make it clear which cache is being loaded & when it is from
      message(glue::glue("Loading cached data ({cached_time}) from: '{cache_object$cache_path}'"))
      # Convert the Cache time to UTC as this is what is accepted by esri api
      # I may need to use force_tz here
      cached_time <- lubridate::with_tz(cached_time, tzone = "UTC")
      cache_object$data_cache <- geojsonsf::geojson_sf(cache_object$cache_path)
      # Order the columns as per the layer from arcgis
      cache_object$data_cache <- dplyr::select(cache_object$data_cache,
                                               # Using Any Of as sometimes the column names may not be present
                                               dplyr::any_of(field_names(layer_details)))
      # parse the types
      cache_object$data_cache <- parse_types(x = cache_object$data_cache, layer_details = layer_details)
      cache_object$any_changes <- last_layer_edit > cached_time


      # Check which object IDs are in the data cache
      ids_in_cache <- dplyr::pull(cache_object$data_cache, cache_object$id_field)

      # Drop any IDs not requested from the cache
      cache_object$data_cache <- dplyr::filter(cache_object$data_cache,
                                               ids_in_cache %in% cache_object$query_object_ids$objectIds)

      # Keep only IDs which aren't already in the cache
      not_cached_object_ids <- cache_object$query_object_ids$objectIds[!cache_object$query_object_ids$objectIds %in% ids_in_cache]

      # Set 'any_changes' to true if there are object ids requested which aren't in the cache
      cache_object$any_changes <- length(not_cached_object_ids) > 0 | cache_object$any_changes

      # If:
      # - there haven't been any edits since the data was last cached, and
      # - the cache contains all object ids requested (no additional object ids to request) or
      # - the method is using layer edits then return the object
      if (!cache_object$any_changes | cache_object$method == "layer_edit" ) {
        return(cache_object)
      }

      # Otherwise generate an edits query
      # Generate the edits query from the field records the edit times and the last download time
      # Between the time the data is downloaded and written to file, there will be  gap where some edits are missed
      # I need a way of recording the actual dl time in the file
      edits_query <-
        glue::glue(
          "{layer_details$editFieldsInfo$editDateField} > '{as.character(cached_time)}'"
        )

      ## Change the where query to request the object ids (which i've already requested)
      # rather than sending over all the query data (which may be large if it includes spatial data)
      cache_object$query$where <-
        id_query(object_id_name = cache_object$query_object_ids$objectIdFieldName,
               object_ids = cache_object$query_object_ids$objectIds,
               map_server = map_server(endpoint))

      # Combine the edits and OID query
        cache_object$query$where <- glue::glue("({cache_object$query$where}) AND {edits_query}")

    cache_object$object_ids <-
      get_feature_ids(endpoint = endpoint,
                      query = cache_object$query,
                      my_token = my_token)

    # Add in any object IDs which weren't the cached doesn't already include but may not have changed
    # and therefore wouldn't be picked up in the edits query
    # Sort them so that the data is returned in the correct order (not sure if this is actually)
    # neccessary
    cache_object$object_ids$objectIds <- unique(sort(c(cache_object$object_ids$objectIds, not_cached_object_ids)))

    return(cache_object)
  }}

#' Refresh cache
#'
#' Refresh the data cache
#' @param data the newly downloaded data
#' @param cache_object the cache object generated by init_cache
#' @return a tibble
refresh_cache <-
  function(data, cache_object){
    if (!cache_object$use_cache) {
      data <- order_data_by_oid(data = data, cache_object = cache_object)
      return(data)
      }

    # Write Cache
    if (!cache_object$cache_exists) {
      data <- order_data_by_oid(data = data, cache_object = cache_object)
      sf_geojson_write(sf = data,
                       filepath = cache_object$cache_path)
      return(data)
    }

    # If there are no rows in the cache and there are in the data then write the data
    # and return it
    # This avoids an error that occurs when the cache data is loaded from a layer with no
    # features when cached and a row has been added, meaning the onject ID col isn't present in cache
    if(nrow(cache_object$data_cache) == 0 &
       nrow(data) != 0) {
      sf_geojson_write(sf = data,filepath = cache_object$cache_path)
      return(data)
    }


    new_data_ids <- dplyr::pull(data, cache_object$id_field)
    cache_data_ids <- dplyr::pull(cache_object$data_cache, cache_object$id_field)


    data_refreshed <-
      dplyr::bind_rows(
        # Remove anything from the cache that has been updated
        dplyr::filter(cache_object$data_cache, !cache_data_ids %in% new_data_ids | cache_data_ids %in% cache_object$object_ids$objectIds),
        data
      )

    # Order it so it matches the format that would be returned by a normal query
    data_refreshed <- order_data_by_oid(data = data_refreshed, cache_object = cache_object)
    # Write the data to the cach
    sf_geojson_write(sf = data_refreshed, filepath = cache_object$cache_path)

    return(data_refreshed)
  }
