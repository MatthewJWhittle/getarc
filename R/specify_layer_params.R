#' Specify Layer Parameters
#'
#' Specify the request parameters of a layer
#'
#' @param host url for the ArcGIS Server host e.g 'https://services9.arcgis.com'
#' @param instance a string defining the ArcGIS Server instance
#' @param feature_server a string defining the name of the feature server
#' @param layer_id an integar defining the layer id (starting at 0)
#' @return a function that can be used to query the features of that layer
#' @export specify_layer_params


specify_layer_params <- function(host,
                                 instance,
                                 feature_server,
                                 layer_id = 0, query = NULL) {
  function(my_token = NULL, out_crs = 4326, query) {
    get_layer(
      host,
      instance,
      feature_server,
      my_token = my_token,
      crs = out_crs,
      layer_id,
      query = query
    )
  }
}
