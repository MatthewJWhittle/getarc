#' Feature Server Endpoint
#'
#' Create a feature server endpoint string from url parameters
#'
#' @param host a string, defining the url for the ArcGIS Server host e.g 'https://services.arcgis.com'
#' @param instance a string defining the ArcGIS Server instance
#' @param feature_server a string defining the name of the feature server
#' @param layer_id an integar defining the layer id (beginning at 0)
#' @return a string defining the endpoint url
#' @importFrom magrittr %>%
feature_server_endpoint <-
  function(host,
           instance,
           feature_server,
           layer_id = 0) {

    rest <- "rest"
    services <- "services"
    server_type <- "FeatureServer"
    request_type <- "query"

    if(!grepl("arcgis", instance)){
      instance <- paste0(instance, "/arcgis")
    }
    endpoint <-
      list(host,
           instance,
           rest,
           services,
           feature_server,
           server_type,
           layer_id) %>% paste0(collapse = "/")

    return(paste0(endpoint, "/"))

  }
