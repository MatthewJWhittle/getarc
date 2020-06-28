#' Parse Query URL
#'
#' Parse a query url to return an R function to get the data
#'
#' This function enables the user to supply a
#' query url for a data source and it will parse the parameters returning a function
#'
#' @param url a string defining the url of the query.
#' @import stringr
#' @importFrom magrittr %>%
#' @importFrom utils URLdecode
#' @return a function created by \code{specifiy_layer_params}
#' @export parse_query_url
#' @examples
#' # Specify the URL for SSSIs
#' url <- "https://services.arcgis.com/JJzESW51TqeY9uat/arcgis/rest/services/SSSI_England/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
#' # Parse the url into a get function
#' get_sssi <- parse_query_url(url)
#' # Get the data, passing an additional parameter to only return one feature
#' one_sssi <- get_sssi(query = c("resultRecordCount" = "1"))

parse_query_url <-
  function(url) {
    url <- URLdecode(url)
    host <- str_extract(url, "^https.+(\\.com)")
    instance <-
      str_remove(url, host) %>% str_extract("^/([A-Za-z0-9]+)?/?arcgis") %>% str_remove_all("^/|/$")

    server_type <- str_extract(url, "FeatureServer|MapServer")

    data_source <-
      str_extract(url, paste0("services", "/.+/", server_type)) %>%
      str_remove_all(paste0("(services/)", "|(/", server_type, ")"))

    layer_id <-
      str_extract(url, "(Map|Feature)Server/.+/query") %>% str_remove_all("(Map|Feature)Server/|/query")

    folder <- NULL
    service_name <- NULL
    feature_server <- NULL

    if (server_type == "MapServer") {
      source_split <- str_split(data_source, "/", n = 2)
      folder <- source_split[[1]][[1]]
      service_name <- source_split[[1]][[2]]
    } else{
      feature_server <-
        str_extract(url, "services/.+/FeatureServer") %>% str_remove_all("services/|/FeatureServer")
    }

    make_query_function(
      server_type = server_type,
      host = host,
      instance = instance,
      feature_server = feature_server,
      folder = folder,
      service_name = service_name,
      layer_id = layer_id
    )
  }
