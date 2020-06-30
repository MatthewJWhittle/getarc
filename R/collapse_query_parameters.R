#' Collapse Query Parameters
#'
#' Helper function to collapse parameters into a typical url query
#'
#' @import purrr
#' @importFrom magrittr %>%
#' @param  x a named list of query parameters
#' @param drop_null logical value should null list elements be dropped
#' @return a string of query parameters
collapse_query_parameters <-
  function(x, drop_null = FALSE) {
    # Map in parallel along the query param list
    # Paste the names of the list and values seperated by =
    # Collapse all parameters by &

    if(drop_null){
      x <- x[!unlist(lapply(x, is.null))]
    }

    purrr::map2(.x = x,
                .y = names(x),
                ~ (function(param, value) {
                  paste0(param, "=", value)
                })(param = .y, value = .x)) %>%
      paste0(collapse = "&")
  }
