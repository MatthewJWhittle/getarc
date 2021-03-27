#' Spatial Query
#'
#' Convert SF/SFC to spatial query.
#'
#' This function accepts an sf/sfc object and converts it to a spatial query fitting the esri api spec.
#' @param x an sf or sfc object
#' @param spatial_filter the spatial relationship of the filter to specify in the query. Default is esriSpatialRelIntersects.
#' Options are: esriSpatialRelIntersects, esriSpatialRelContains, esriSpatialRelCrosses, esriSpatialRelEnvelopeIntersects,
#' esriSpatialRelIndexIntersects, esriSpatialRelOverlaps, esriSpatialRelTouches or esriSpatialRelWithin.
#' @return a list with geometry, geometryType, SpatialRel and inSR
#' @importFrom sf st_geometry
#' @importFrom sf st_crs
spatial_query <-
  function(x, spatial_filter = "esriSpatialRelIntersects") {
    x_class <- class(x)
    stopifnot(any(c("bbox", "sf", "sfc") %in% x_class))
    stopifnot(is.character(spatial_filter))
    if("bbox" %in% x_class){
      # If x is a bounding box, then use this method as it is less characters and will speed up request
      list(
        geometry = paste0(x, collapse = ","),
        geometryType = "esriGeometryEnvelope",
        spatialRel = spatial_filter,
        inSR = sf::st_crs(x)$epsg
      )
    }else{
      # Otherwise, convert the object to sfc, then to json and specify the type
      x <- sf::st_geometry(x)
      stopifnot(length(x) == 1)
      #x_simple <- simplify_sf_to_nchar(x, char = max_char)
      list(
        geometry = sf_to_json(x),
        # Only certain types accepted by this function
        geometryType = esri_geometry_type(x),
        spatialRel = spatial_filter,
        inSR = sf::st_crs(x)$epsg
      )
    }
  }
#' sf to json
#'
#' Convert an sfc object to json
#'
#' This function accepts an sf object and converts it to json (not geojson). This format is required by esri for spatial queries.
#' @param x an sf or sfc object
#' @return a character string of json.
#' @importFrom sf st_geometry
#' @importFrom geojsonsf sfc_geojson
#' @importFrom sf st_crs
#' @importFrom stringr str_remove_all
#' @importFrom glue glue
#' @importFrom dplyr filter
#' @importFrom sf st_coordinates
#' @importFrom sf st_zm
#' @importFrom sf st_geometry_type
sf_to_json <-
  function(x) {
    # Drop the z & m dimensions as I don't know how to tell if they are present
    x <- sf::st_zm(x, drop = TRUE)
    # Check the geom type  to conver to its json spec (rings, points , paths)
    x_geom_type <- sf::st_geometry_type(x)
    # Don't query if the geom type isn't supported
    stopifnot(x_geom_type %in% getarc::esri_sf_type_lookup$sf)
    json_type <- dplyr::filter(getarc::esri_sf_type_lookup, sf == x_geom_type)$json

    # Convert the boundary to an sfc objet
    x_sfc <- sf::st_geometry(x)
    stopifnot(length(x_sfc) == 1)

    # Extract the EPSG code
    crs <- sf::st_crs(x_sfc)$epsg
    # If the geometry type is a point, the function needs to return the json in a different way
    if(json_type == "point"){
      xy <- sf::st_coordinates(x)
      return(
        glue::glue('{"x" : (xy[,1]), "y" : (xy[,2]), "spatialReference" : {"wkid" : (crs)}}',
                   .open = "(",
                   .close = ")"
        )
      )
    }


    # First convert the boundary to geojson as this is closer to the required format
    x_geojson <- geojsonsf::sfc_geojson(x_sfc)

    # Strip out everything outside the rings
    rings <- stringr::str_remove_all(x_geojson, "\\{.+:|\\}")

    # sfc_geojson adds one too many pairs of enclosing brackets
    # Its neccessary to remove one layer. This works for simple text
    # case with two adjecent boxes. Need to test more widely
    # Could make this conditional on geometry being a multipolygon
    rings <-
      rings %>%
      stringr::str_replace_all("\\[\\[\\[\\[", "[[[") %>%
      stringr::str_replace_all("\\]\\]\\]\\]", "]]]") %>%
      stringr::str_replace_all("\\]\\]\\],\\[\\[\\[", "]],[[")

    # Format the json and return
      glue::glue('{"hasZ" : false, "hasM" : false,
           "(json_type)" : (rings), "spatialReference" : {"wkid" : (crs)}}',
                 .open = "(",
                 .close = ")")
  }
#' ESRI Geometry Type
#'
#' Convert SF to ESRI geometry types
#'
#' This finds the corresponding esri types for an sf object.
#' @param x an sf or sfc object
#' @return a character string detailing the geometry type
#' @importFrom sf st_geometry_type
#' @importFrom dplyr filter
esri_geometry_type <-
  function(x) {
    # Assert that it is class sf or sfc
    stopifnot(any(c("sf", "sfc") %in% class(x)))
    # Determine the SF type of the object and convert this to a character string
    x_type <- as.character(sf::st_geometry_type(x))
    # The function only works with one feature currently. It could be expanded to work with more but this isn't needed right now.
    stopifnot(length(x_type) == 1)
    # Only certain types are accepted at the moment. This is because I don't know
    # how types like 'triangle' should fit into the esri types which are less details.
    # Requires some testing to figure out. Probably everything else would fit into olygon
    stopifnot(x_type %in% getarc::esri_sf_type_lookup$sf)
    # Return the corresponding esri type
    dplyr::filter(getarc::esri_sf_type_lookup, .data$sf == x_type)$esri
  }
#' Simplify sf to length
#'
#' Simplify SF to N Char
#'
#'
#' @param x an sf object to simplify
#' @param char numeric - the number of characters to simplify to based on st_as_text
#' @importFrom sf st_as_text
#' @importFrom sf st_transform
#' @importFrom sf st_simplify
simplify_sf_to_nchar <-
  function(x, char) {
    stopifnot("sfc" %in% class(x))
    in_crs <- sf::st_crs(x)
    x <- sf::st_transform(x, crs = 27700)
    x_char <-  nchar(sf::st_as_text(x))
    # Don't execute the function if the character length is sufficiently low
    if(x_char <= char){return(sf::st_transform(x, crs = in_crs))}
    factor <- x_char / char

    # simplify x with increasing dtolerance
    # The effect of increasing dTolerance dimishes as x is simplified
    # So the factor is doubled on each iteration
    while (nchar(sf::st_as_text(x)) > char) {
      x <- sf::st_simplify(x, dTolerance = factor)
      factor <- factor * 2
    }
    # It would be faster to calculate the amount of simplification required and do it once.
    message(
      paste0(
        "Boundary simplified for request. Returned records may not all be within supplied boundary.\nTo get all records within the boundary try applying a buffer and cropping the records."
      )
    )
    return(sf::st_transform(x, crs = in_crs))
  }

#' Esri Spatial Filter
#'
#' Filter Name to Esri
#'
#' This function converts the shortened version of an esri filter to it's esri filter name
#' @param spatial_filter the short name for the spatial filter. Should be one of intersects, contains, crosses, envelope_intersects, index_intersects, overlaps, touches or within
#' @return the full name of the esri filter
esri_spatial_filter <-
  function(spatial_filter) {
    lookup <-
      c(
        "intersects" = "esriSpatialRelIntersects",
        "contains" = "esriSpatialRelContains",
        "crosses" = "esriSpatialRelCrosses",
        "envelope_intersects" = "esriSpatialRelEnvelopeIntersects",
        "index_intersects" = "esriSpatialRelIndexIntersects",
        "overlaps" = "esriSpatialRelOverlaps",
        "touches" = "esriSpatialRelTouches",
        "within" = "esriSpatialRelWithin"
      )
    # Return the filter if it already matches an esri type
    if(spatial_filter %in% lookup){
      return(spatial_filter)
    }
    if(!(spatial_filter %in% names(lookup))){
      stop(paste0("spatial_filter did not match any of: ", paste0(names(lookup), collapse = ", ")))
    }
    unname(lookup[spatial_filter])
  }
