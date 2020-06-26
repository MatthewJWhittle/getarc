#' Get feature data
#'
#' Download feature layer from a feature server
#'
#' @param host url for the ArcGIS Server host e.g 'https://services9.arcgis.com'
#' @param instance a string defining the ArcGIS Server instance
#' @param feature_server a string defining the name of the feature server
#' @param layer_id an integar defining the layer id (starting at 0)
#' @param my_token an access token acquired via \code{get_token}
#' @param query a named vector of parameters to include in the query
#'
#' @return an sf object
#' @export get_layer
#'
#' @import httr
#' @import sf
#' @importFrom magrittr %>%


get_layer <-
  function(host,
           instance,
           feature_server,
           my_token = NULL,
           crs = 4326,
           layer_id = 0,
           query = NULL) {
    #https://developers.arcgis.com/rest/services-reference/layer-feature-service-.htm


    rest <- "rest"
    services <- "services"
    server_type <- "FeatureServer"
    request_type <- "query"

    endpoint <-
      list(
        host,
        instance,
        "ArcGIS",
        rest,
        services,
        feature_server,
        server_type,
        layer_id,
        request_type
      ) %>% paste0(collapse = "/")


    # Parameter spec -------------------------
    f <- "json"
    # "where=FID>=0" was causing a 400 error
    # This where clause is taken from the natural england arc gis api example
    where <- "1=1"

    # Get the token from the supplied access token
    if (!is.null(my_token)) {
      token <- parse_access_token(my_token)
    } else{
      token <- my_token
    }

    # Define a list of essential parameters
    essential_parameters <-
      list(
        f = f,
        token = token,
        # Get all features with sql query 1 = 1
        where = where,
        # Assert that the data is lat lon if writing to geojson
        outSR = 4326
      )

    # Define a list of default parameters
    default_parameters <-  list(
      returnIdsOnly = "false",
      outFields = "*",
      returnCountOnly = "false"
    )


    # Drop any parameters specified by the user in query from the list of standard parameters
    default_parameters <- default_parameters[!names(default_parameters) %in% names(query)]



    query_list <- c(essential_parameters, default_parameters, query)



    # Collapse the parameters into a string of length 1
    # The drop_null argument enables the function to drop NULL tokens
    # This is accounts for services that don't require an api token
    query_string <- collapse_query_parameters(query_list, drop_null = TRUE)

    # Create a temporary file for caching the spatial data
    temp_file <- tempfile(fileext = ".geojson")
    # Request the spatial data and write it to a temporary file as JSON
    request <-
      httr::GET(paste0(endpoint, "?", query_string),
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

    # If the specified crs is not 4326 (the current crs) then transform the data
    if (crs != 4326) {
      data <- data %>% sf::st_transform(crs = crs)
    }
    return(data)
  }
