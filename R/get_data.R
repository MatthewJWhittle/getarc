#' Get GeoJSON
#'
#' Download geojson from a query url
#'
#' This function downloads geojson from a query_url, writes it to a temporary file and reads it in usinf st_read
#'
#' @param query_url the query url which is passed to httr::POST()
#' @param query the query to POST
#' @return an sf object
#' @importFrom sf st_read
#' @importFrom magrittr %>%
#' @importFrom httr POST
#' @importFrom httr write_disk
#' @importFrom httr status_code
#' @importFrom httr content
#' @import purrr
get_geojson <- function(query_url, query) {

  # Request the data using POST
  response <- httr::POST(url = query_url, body = as.list(query))

  # Fail on error
  stopifnot(httr::status_code(response) == 200)

  content <- httr::content(response, as = "text")
  # Check for an error if it doesn't return api fail
  check_esri_error(content = content)
  # Read the data from the json text
  data <- sf::st_read(dsn = content,
                      quiet = TRUE, stringsAsFactors = FALSE)

  # Possibly return the data or an error
  if (is.null(data)) {

    stop(paste0("Error: ",
                print(httr::content(response))))
  }

  return(data)

}
#' Get Tibble
#'
#' Get a Tibble from an endpoint
#'
#' This function accepts a query URL and extracts a tibble from the response.
#' @param query_url  the query url which is passed to httr::POST()
#' @param query the query to POST
#' @return a tibble
#' @importFrom httr POST
#' @importFrom httr status_code
#' @importFrom httr content
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @importFrom purrr map
#' @importFrom dplyr bind_rows
get_tibble <-
  function(query_url, query){
    # Request the data using POST
    response <- httr::POST(url = query_url, body = as.list(query))


    # Fail on error
    stopifnot(httr::status_code(response) == 200)
    # First convert JSON to a list.
    # This list contains multiple levels with information about the data
    # The desired table is contained in data_list$features$attributes
    # Extract and return it
    content <- httr::content(response)
    # Check for an error if it doesn't return api fail
    check_esri_error(content = content)
    # I've added some control flow in here to modulate the behaviour if it is a map server
    if(map_server(query_url)){
    # Map servers return data in a different format which needs a different method of parsing
      data <-
        dplyr::bind_rows(purrr::map(content$features,
                           "attributes"))
    }else{
    data_list <- jsonlite::fromJSON(content)
    data <- tibble::as_tibble(data_list$features$attributes)
    }
    return(data)
  }

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
#' @return either a tibble or sf object depending on return_geometry
get_data <-
  function(query_url, query, return_geometry) {
    # only tick if it exists
    if(exists("pb")) {
      pb$tick()
    }
    if (return_geometry) {
      data <- get_geojson(query_url = query_url, query = query)
    } else{
      data <- get_tibble(query_url = query_url, query = query)
    }
    return(data)
  }
