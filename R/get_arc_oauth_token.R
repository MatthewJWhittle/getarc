
get_arc_oauth_token <-
  function(use_cache = TRUE) {
    client_id <- "VOIwOYFeZisqisjy"
    # Client secret embedded in source code as recomended by:
    # https://cran.r-project.org/web/packages/httr/vignettes/secrets.html
    client_secret <-"0229069bd415471d93def4c43b0ac69a"
    endpoint <-
      httr::oauth_endpoint(access = "https://www.arcgis.com/sharing/rest/oauth2/token/",
                     authorize  = "https://www.arcgis.com/sharing/rest/oauth2/authorize/")
    app <-
      httr::oauth_app(appname = "query habitats",
                key = client_id,
                secret = client_secret)

    my_token <-
      httr::oauth2.0_token(endpoint = endpoint, app = app, cache = use_cache)
    return(my_token)
  }
