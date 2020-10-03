#' Find oauth2.0 error
#'
#' Find oauth errors
#'
#' This function is borrowed from the httr package
#'
#' @param response a respoonse object returned by a request to refresh a token
#' @importFrom httr status_code
#' @importFrom httr content
#' @source https://cran.r-project.org/package=httr

# This implements error checking according to the OAuth2.0
# specification: https://tools.ietf.org/html/rfc6749#section-5.2
find_oauth2.0_error <- function(response) {
oauth2.0_error_codes <- c(
  400,
  401
)

oauth2.0_errors <- c(
  "invalid_request",
  "invalid_client",
  "invalid_grant",
  "unauthorized_client",
  "unsupported_grant_type",
  "invalid_scope"
)
  if (!httr::status_code(response) %in% oauth2.0_error_codes) {
    return(NULL)
  }

  content <- httr::content(response)
  if (!content$error %in% oauth2.0_errors) {
    return(NULL)
  }

  list(
    error = content$error,
    error_description = content$error_description,
    error_uri = content$error_uri
  )
}
