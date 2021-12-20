#' Parse ESRI JSON
#'
#' Parse the JSON response of the API
#'
#' Conditionally parse the JSON response of the API depending on whether it is a table of layer (e.g. has geometry)
#'
#' @param x an R list of data returned by the APPI (parsed JSON returned by the API)
#' @param geometry is there a geometry element to the json? TRUE/FALSE
#' @importFrom  purrr map
#' @importFrom purrr flatten
#' @importFrom rjson fromJSON
#' @return a tibble or sf object
parse_esri_data <-
  function(x, geometry){
    # Define the parsing function (either a layer or a table)
    # This reduces duplication in the code by having one process
    if(geometry){parse_data <- parse_layer}else{parse_data <- parse_table}

    # Check the length of the list & parse the first element if it is only one length lol
    if(length(x) == 1){return(parse_data(x[[1]]))}

    ## Combine the listof json into one properly formatted json list ##
    # Create vectors which define the different data keys (metadata & features)
    metadata_keys <- c("displayFieldName", "fieldAliases", "geometryType", "spatialReference", "fields")
    feature_keys <- c("features")

    # Parse the JSON into a list of lists
    #parsed_list <- purrr::map(x, rjson::fromJSON)

    # Extract the features from all elements and the metadata from the first (since it is repeated)
    features <- purrr::flatten(purrr::map(x, ~ .x[[feature_keys]]))
    combined_list <- c(x[[1]][metadata_keys], list(features = features))

    # Convert back to json and read it using sf::st_read
    # It would probably be faster but more complicated to construct the sf object from the list
    parse_data(combined_list)
  }
#' Parse JSON Table
#'
#' Parse an ESRI json response into a table
#' @param x ESRI JSON (not GeoJSON)
#' @return a tibble
#' @importFrom purrr map_df
#' @importFrom rjson fromJSON
#' @importFrom tibble as_tibble
parse_table <-
  function(x){
    feature_list <- purrr::map(x$features, "attributes")
    # If NULLs are returned by the API, then these are automatically dropped
    # When the api only returns NULL values, bind_rows fails
    feature_list <- purrr::map_depth(feature_list, .depth = 2, replace_null)

    # Then bind the data to a tibble
    dplyr::bind_rows(feature_list)
  }
#' Parse JSON Layer
#'
#' Parse an ESRI json response into an SF object
#' @param x ESRI JSON (not GeoJSON)
#' @return an sf object
#' @importFrom sf st_read
#' @importFrom rjson toJSON
parse_layer <-
  function(x){
    sf::st_read(rjson::toJSON(x), quiet = TRUE, stringsAsFactors = FALSE)
  }
