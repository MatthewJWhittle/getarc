#' Get Data
#'
#' Get data from an endpoint
#'
#' This function accepts a query URL and extracts a tibble from the response.
#' When a returnGeometry = "false" query was used previously
#' get_geojson wouldn't parse the data correctly and would return an empty tibble
#' A new function get_tibble has been added to use a different method for requesting and parsing data
#' when the geometry isn't returned.
#' @param query_url  the query url which is passed to httr::POST()
#' @param query the query to POST
#' @param return_geometry should the geometry be returned, this is passed in to query_layer & must also from part of the query
#' @param pb progress bar - default is NULL for no progress bar
#' @param my_token the access token or function used to generate one
#' @return either a tibble or sf object depending on return_geometry
get_data <-
  function(query_url,
           query,
           return_geometry,
           pb = NULL,
           my_token) {

    # Add the token into the query
    query <-
      utils::modifyList(query, list(token = parse_access_token(my_token)), keep.null = FALSE)

    # only tick if it exists
    if (!is.null(pb)) {
      pb$tick()
    }
    # Request the data using POST
    response <- httr::POST(url = query_url, body = query)
    # Fail on error
    stopifnot(httr::status_code(response) == 200)

    content <- httr::content(response, as = "text")
    # Check for an error if it doesn't return api fail
    check_esri_error(content = content)

    # Check if no features have been returned and return an empty sf object
    # This avoids st_read hitting an error where no features are returned
    # if(grepl('"features":\\[\\]', content)){return(sf::st_sf(sf::st_sfc()))}

    return(content)
  }

#' Parse GeoJSON list
#'
#' Parse a list of geojson strings
#'
#' This function parses a list of geojson strings. It is a faster method
#' than parsing geojson individually and then combining them into one dataframe so speeds
#' up the process of getting data. The improved speed is most noticable for large geojson strings
#' or where there are many parts. Performance improvements won't be noticable for small lists
#' @param geojson_list a list of geojson strings to be parsed into an sf object
#' @param has_geometry does the json h
#' @return an sf object of all geojson parts combined
combine_parse_esri_json <-
  function(json_list, has_geometry = TRUE){
    # This function provides a method to combine multiple GeoJSON strings into one (technically JSON) string
    # This is done via rjson::fromJSON which combines and simplifies the duplicated geojson elements
    # So that there is only one type, geometry and properties element for each
    # fromJOSN converts it to an R list which is then converted back to JSON which is now correctly formatted
    # geojson which can be read by geojsonsf::geojson_sf
    # e.g.
    # "{{
    #   "type": "Feature",
    #   "geometry": {[...]},
    #   "properties": {[...]}
    # },
    # {
    #   "type": "Feature",
    #   "geometry": {[...]},
    #   "properties": {[...]}
    # }}"
    ###
    # Becomes:
    #  {
    #   "type": "Feature",
    #   "geometry": {[[...], [...]]},
    #   "properties": {[[...], [...]]}
    # }
    if(has_geometry){
      read_data <- purrr::partial(sf::st_read, quiet = TRUE, stringsAsFactors = FALSE)
    }else{
      read_data <- parse_esri_json_table
    }
    # First check the length of geojson list & parse first element if only length 1
    if(length(json_list) == 1){
      return(read_data(json_list[[1]]))
    }
    # Collapse the GeoJSON strings into one string and convert to an R list to combine elements
    combined_json <- rjson::fromJSON(paste0(json_list, collapse = ", "))
    # Then convert back to geojson and parse to an sf
    read_data(rjson::toJSON(combined_json))
  }

#' Parse ESRI JSON tables
#'
#' Parse ESRI JSON (without geometry) into a table
#'
#' This function accepts esrijson and parses it as a table
#' @param json ESRI json representing a table
parse_esri_json_table <-
  function(json) {
    layer <- rjson::fromJSON(json)
    # I've added some control flow in here to modulate the behaviour if it is a map server
    # if(map_server(query_url)){
    # Map servers return data in a different format which needs a different method of parsing
    feature_list <-
      purrr::map(layer$features,
                 "attributes")
    # If NULLs are returned by the API, then these are automatically dropped
    # When the api only returns NULL values, bind_rows fails
    feature_list <-
      purrr::map_depth(feature_list,
                       .depth = 2,
                       replace_null)

    # Then bind the data to a tibble
    dplyr::bind_rows(feature_list)
  }
