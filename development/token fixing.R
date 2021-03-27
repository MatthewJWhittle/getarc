devtools::load_all()
client_id = "yKYDBnaubsMqB4qv"
client_secret = "2337a5f0d4ba4ff3a8f3229b26303cc4"
app_name = "getarc"
redirect_uri = httr::oauth_callback()
use_cache = TRUE

credentials <- list(client_id = client_id,
                    client_secret = client_secret,
                    app_name = app_name)

if(any(purrr::map_lgl(credentials, is.null))){
  # message("Getting credentials from environment variables")
  credentials <- get_credentials()
}
endpoint <-
  httr::oauth_endpoint(access = "https://www.arcgis.com/sharing/rest/oauth2/token/",
                       authorize  = "https://www.arcgis.com/sharing/rest/oauth2/authorize/")
app <-
  httr::oauth_app(appname = credentials$app_name,
                  key = credentials$client_id,
                  secret = credentials$client_secret,
                  # When other people try to run get token they get an eror saying
                  # incorrect redirect_uri. I wonder if this is because different users
                  # have a different default uri. It is possible to reproduce the error by setting
                  # the redirect uri below to one that doesn't match the app set up in arc
                  # Doesn't work on RStudio Server
                  redirect_uri = redirect_uri)

# With the request send the datetime which is then automatically stored with the token
# This is then checked against the expiry seconds and the token is refreshed if neccessary
my_token <-
  httr::oauth2.0_token(endpoint = endpoint, app = app, cache = use_cache,
                       query_authorize_extra = list(grant_datetime = Sys.time()))

# httr doesn't parse the credentials correctly into a list
my_token$credentials <- jsonlite::fromJSON(my_token$credentials)

# Check expiry and refresh if neccessary
# The refresh token is an alteration to httr:::refresh_oauth2.0
if(auto_refresh & token_expired(my_token)){
  my_token$credentials <-
    refresh_token(
      endpoint = endpoint,
      app = app,
      credentials = my_token$credentials,
      user_params = NULL
    )
  my_token$params$query_authorize_extra$grant_datetime <-
    Sys.time()
}
