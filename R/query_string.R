#' Query String
#'
#' Generate a query string to combine with the endpoint
#'
#'  This function accepts a named list or vector of query parameters. It compares the
#'  parameters with standard parameters and returns a string.
#'  @param a named list or vector of query parameters where the names are the
#'  parameter names and the values are the parameter values. For example: list(outFields = "*")
#'  @param my_token An access token to be included in the string if specified
#'  @return a string, beginning with "query?" to concatenate with the end point
query_string <-
  function(query, my_token = NULL) {

    # "where=FID>=0" was causing a 400 error


    # Get the token from the supplied access token
    if (!is.null(my_token)) {
      token <- parse_access_token(my_token)
    } else{
      token <- my_token
    }

    # Define a list of essential parameters
    essential_parameters <-
      list(
        f = "json",
        token = token,
        # Assert that the data is lat lon if writing to geojson
        outSR = 4326
      )


    # Define a list of default parameters
    default_parameters <-  list(
      returnIdsOnly = "false",
      # Get all features with sql query 1 = 1
      where = "1=1",
      outFields = "*",
      returnCountOnly = "false"
    )


    # Drop any parameters specified by the user in query from the list of standard parameters
    default_parameters <-
      default_parameters[!names(default_parameters) %in% names(query)]



    query_list <- c(essential_parameters, default_parameters, query)



    # Collapse the parameters into a string of length 1
    # The drop_null argument enables the function to drop NULL tokens
    # This is accounts for services that don't require an api token
    query_string <-
      collapse_query_parameters(query_list, drop_null = TRUE)

    paste0("query?", query_string)
  }
