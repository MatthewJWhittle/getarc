#' Make a query function
#'
#' Specify the request parameters of a layer to generate a query function
#'
#' @param server_type one of c("MapServer", "FeatureServer")
#' @param host url for the ArcGIS Server host e.g 'https://services9.arcgis.com'
#' @param instance a string defining the ArcGIS Server instance
#' @param feature_server a string defining the name of the feature server (only required for feature servers)
#' @param folder a string defining the data folder (only required for map servers)
#' @param service_name a string defining the service name (only required for map servers)
#' @param layer_id an integar defining the layer id (starting at 0)
#' @return a function that can be used to query the features of that layer
#' @export make_query_function
make_query_function <- function(server_type,
                                host,
                                instance,
                                feature_server = NULL,
                                folder = NULL,
                                service_name = NULL,
                                layer_id = 0) {
  function(my_token = NULL,
           out_crs = 4326,
           query = NULL,
           bounding_box = NULL) {
    if (server_type == "MapServer") {
      query_layer_ms(
        host = host,
        instance = instance,
        folder = folder,
        service_name = service_name,
        layer_id = layer_id,
        my_token = my_token,
        crs = out_crs,
        query = query,
        bounding_box = bounding_box

      )
    } else{
      query_layer_fs(
        host = host,
        instance = instance,
        feature_server = feature_server,
        layer_id = layer_id,
        my_token = my_token,
        crs = out_crs,
        query = query,
        bounding_box = bounding_box
      )
    }
  }
}
