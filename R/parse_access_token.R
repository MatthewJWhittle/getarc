#' Parse Access Token
#'
#' Helper function to parse access tokens
#'
#' @param my_token an access token acquired via get_token or a function used to generate the access token
#' @return the access token as a string
parse_access_token <-
  function(my_token){
    # Check that a valid token has been passed in
    # This have been changed now it needs to be more flexible and accept character tokens
    stopifnot(is.null(my_token) || c("Token") %in% class(my_token) || is.character(my_token) || is.function(my_token))
    # First return the NULL token if it is NULL to avoid further errors
    if(is.null(my_token)){return(my_token)}

    # If the token has been passed in as a function, then execute it to get the result
    # This allows the user to pas in a functional to generate the token
    # this is useful when the token is short lived and the user is querying for many FIDs
    if(is.function(my_token)){my_token <- my_token()}

    # This allows us to deal with access tokens that are generate by generate Tokens process
    # Not by oauth2.0
    if(is.character(my_token)){return(my_token)}
    my_token$credentials$access_token
  }
