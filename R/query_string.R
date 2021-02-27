#' Query String
#'
#' Generate a query string to combine with the endpoint
#'
#' This function accepts a named list or vector of query parameters. It compares the
#' parameters with standard parameters and returns a string.
#' @param f return format "json by default
#' @param my_token An access token to be included in the string if specified
#' @param ... additional query parameters passed as named pairs. Names are the parameter names and the values are the parameter values. For example: list(outFields = "*")
#' @return a string, beginning with "query?" to concatenate with the end point
#' @importFrom purrr flatten
#' @importFrom utils URLencode
query_string <-
  function(f = "json",
           my_token = NULL,
           ...){

    # Parse ... arguments and unlist them so there is only one list level
    query <- purrr::flatten(list(...))
    if (!is.null(my_token)) {
      token <- parse_access_token(my_token)
    } else{
      token <- my_token
    }

    # Combine the function args into a list,
    default_parameters <- c(f = f, token = token)
    # Remove any of the default arguments that have been specified in ...
    # This enables the user to overwrite any default parameters

    default_parameters <- default_parameters[!(names(default_parameters) %in% names(query))]

    # Combine all parameters into a named vector for collapsing
    query_parameters  <- c(default_parameters, query)

    # Collapse the parameters into a string of length 1
    # The drop_null argument enables the function to drop NULL tokens
    # This is accounts for services that don't require an api token
    query_string <-
      collapse_query_parameters(query_parameters, drop_null = TRUE)

    # Encode the url to avoid errors due to spaces etc.
    # I have removed 'query' from the paste0 statement as it is not always required.
    utils::URLencode(paste0("?", query_string))
  }
