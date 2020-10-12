#' Get GeoJSON
#'
#' Download geojson from a query url
#'
#' This function downloads geojson from a query_url, writes it to a temporary file and reads it in usinf st_read
#'
#' @param query_url the query url which is passed to httr::GET()
#' @return an sf object
#' @importFrom sf st_read
#' @importFrom magrittr %>%
#' @import httr
#' @import purrr
get_geojson <- function(query_url) {
  # Create a temporary file for caching the spatial data
  temp_file <- tempfile(fileext = ".geojson")
  # Request the spatial data and write it to a temporary file as JSON
  request <-
    httr::GET(query_url,
              httr::write_disk(temp_file, overwrite = T))
  # Fail on error
  stopifnot(httr::status_code(request) == 200)
  # Read the data from the temporary file
  possible_read <- purrr::possibly(sf::st_read, otherwise = NULL)
  data <- possible_read(temp_file, stringsAsFactors = FALSE)

  if (is.null(data)) {

    stop(paste0("Error: ",
                print(httr::content(request))))
  }

  return(data)

}
#' Get Tibble
#'
#' Get a Tibble from an endpoint
#'
#' This function accepts a query URL and extracts a tibble from the response.
#' @param query_url  the query url which is passed to httr::GET()
#' @return a tibble
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom httr status_code
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @importFrom purrr map
#' @importFrom dplyr bind_rows
get_tibble <-
  function(query_url){
    # Request the data using GET
    response <- httr::GET(paste0(query_url))

    # Fail on error
    stopifnot(httr::status_code(response) == 200)
    # Firs4t convert JSON to a list.
    # This list contains multiple levels with information about the data
    # The desired table is contained in data_list$features$attributes
    # Extract and return it
    content <- httr::content(response)
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
