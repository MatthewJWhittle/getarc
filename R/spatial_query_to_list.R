#' Generate a Spatial Query
#'
#' Generate a list of spatial query parameters from a bounding box
#'
#' @param bbox a bounding box created by st_bbox()
#' @return a list of spatial query elements
#' @importFrom sf st_crs
spatial_query_to_list <-
  function(bbox) {
    stopifnot("bbox" %in% class(bbox))
    list(
      geometry = paste0(bbox, collapse = ","),
      geometryType = "esriGeometryEnvelope",
      spatialRel = "esriSpatialRelIntersects",
      inSR = st_crs(bbox)$epsg
    )
  }
