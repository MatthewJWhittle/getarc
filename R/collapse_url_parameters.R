#' Collapse URL Parameters
#'
#' Helper function to collapse parameters into a url
#'
#' @param  x a vector or list of url components
#' @param drop_null logical value should null list elements be dropped
#' @return a string of query parameters
collapse_url_parameters <-
  function(x, drop_null = FALSE) {
    null_params <- lapply(x, is.null)
    null_params <- unlist(lapply(null_params, any))
    if (any(null_params) & drop_null == FALSE) {
      warning(paste(
        sum(null_params),
        " null parameters detected. Set drop_null = TRUE, to drop them."
      ))
    }
    if (drop_null) {
      x_complete_cases <- x[!null_params]
      paste0(x_complete_cases, collapse = "/")
    }else{
      paste0(x, collapse = "/")
    }
  }
