#' Map server endpoint
#'
#' Generate Map Server Endpoint url
#'
#' @param host url for the ArcGIS Server host e.g 'https://services.arcgis.com'
#' @param instance a string defining the ArcGIS Server instance. The default is "arcgis"
#' @param folder a string defining the folder name
#' @param service_name a string defining the name of the service name
#' @param layer_id an integar defining the layer id (starting at 0)
#' @return a string defining the endpoint url
#'
#' @importFrom magrittr %>%
map_server_endpoint <-
  function(host,
           instance = "arcgis",
           folder,
           service_name,
           layer_id = 0) {
    rest <- "rest"
    services <- "services"
    server_type <- "MapServer"
    request_type <- "query"

    endpoint <-
      list(host,
           instance,
           rest,
           services,
           folder,
           service_name,
           server_type,
           layer_id) %>% paste0(collapse = "/")

    return(paste0(endpoint, "/"))
  }
