#' Get Access Token
#'
#' Get an access token for accessing a service
#'
#' @param use_cache should the token be cached? Currently not working
#' @export get_token
#' @import httr
get_token <-
  function(use_cache = FALSE) {
    client_id <- "yKYDBnaubsMqB4qv"
    # Client secret embedded in source code as recomended by:
    # https://cran.r-project.org/web/packages/httr/vignettes/secrets.html
    client_secret <-"2337a5f0d4ba4ff3a8f3229b26303cc4"
    endpoint <-
      httr::oauth_endpoint(access = "https://www.arcgis.com/sharing/rest/oauth2/token/",
                     authorize  = "https://www.arcgis.com/sharing/rest/oauth2/authorize/")
    app <-
      httr::oauth_app(appname = "getarc",
                key = client_id,
                secret = client_secret,
                # When other people try to run get token they get an eror saying
                # incorrect redirect_uri. I wonder if this is because different users
                # have a different default uri. It is possible to reproduce the error by setting
                # the redirect uri below to one that doesn't match the app set up in arc
                redirect_uri = "http://localhost:1410/")

    my_token <-
      httr::oauth2.0_token(endpoint = endpoint, app = app, cache = use_cache)

    return(my_token)
  }
