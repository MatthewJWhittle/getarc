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
#' @param pb progress bar - default is NULL for no progress bar
#' @param my_token the access token or function used to generate one
#' @return either a tibble or sf object depending on return_geometry
#' @importFrom RcppSimdJson fparse
#' @importFrom httr status_code
#' @importFrom httr POST
get_data <-
  function(query_url,
           query,
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

    content <- RcppSimdJson::fparse(response$content, max_simplify_lvl = "list")
    # # Check for an error if it doesn't return api fail
    # check_esri_error(content = content)

    # Check if no features have been returned and return an empty sf object
    # This avoids st_read hitting an error where no features are returned
    # if(grepl('"features":\\[\\]', content)){return(sf::st_sf(sf::st_sfc()))}

    return(content)
  }
