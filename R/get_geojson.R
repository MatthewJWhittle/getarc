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
