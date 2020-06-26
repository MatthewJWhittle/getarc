#' Parse Access Token
#'
#' Helper function to parse access tokens
#'
#' @param my_token an access token acquired via get_token
#' @import jsonlite
parse_access_token <-
  function(my_token){
    creds <- jsonlite::fromJSON(my_token$credentials)
    creds$access_token
  }
