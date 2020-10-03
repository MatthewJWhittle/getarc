#' Parse Access Token
#'
#' Helper function to parse access tokens
#'
#' @param my_token an access token acquired via get_token
#' @importFrom jsonlite fromJSON
#' @return the access token as a string
parse_access_token <-
  function(my_token){
    my_token$credentials$access_token
  }
