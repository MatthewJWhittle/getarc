#' Generate a Spatial Query
#'
#' Generate a list of spatial query parameters from a bounding box
#'
#' Deprecated, please use spatial_query instead
#' @param bbox a bounding box created by st_bbox()
#' @return a list of spatial query elements
#' @importFrom sf st_crs
#' @importFrom lifecycle deprecate_warn
spatial_query_to_list <-
  function(bbox) {
    # Deprecate function
  lifecycle::deprecate_warn(when = "0.0.0.9500", what =  "spatial_query_to_list()", with = "spatial_query()")
    spatial_query(x = bbox)
    # This function is deprecated and spatial queries are now handled by spatial_query.
    # This function accepts bounding boxes as well as other geometry types

    # Old code commented out
    # stopifnot("bbox" %in% class(bbox))
    # list(
    #   geometry = paste0(bbox, collapse = ","),
    #   geometryType = "esriGeometryEnvelope",
    #   spatialRel = "esriSpatialRelIntersects",
    #   inSR = st_crs(bbox)$epsg
    # )
  }
