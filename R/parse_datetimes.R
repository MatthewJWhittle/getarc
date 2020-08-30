#' Parse Datetimes
#'
#' Parse Datetime variables
#'
#' @param data a dataframe / sf object returned by \code{get_geojson}
#' @param feature_details a list object returned by \code{get_layer_details}
#' @return a dataframe or sf object of the same structure as \code{data} but with datetime variables parsed
#' @importFrom purrr map_chr
#' @importFrom sf st_drop_geometry
parse_datetimes <-
  function(data, feature_details){
    # Extract the field names and types to then conditionaly parse them
    if(class(feature_details$fields) == "list") {
      field_names <- purrr::map_chr(feature_details$fields, "name")
      field_types <- purrr::map_chr(feature_details$fields, "type")
    } else{
      field_names <- feature_details$fields$name
      field_types <- feature_details$fields$type
    }

    # Detect date fields to filter the data frame
    date_fields <- field_names[field_types == "esriFieldTypeDate"]
    if(is.null(date_fields)){
      return(data)
    }

    # Conditionally drop the geometry if it is an sf class
    if(class(data) == c("sf", "data.frame")){
    data[date_fields] <-
      lapply(sf::st_drop_geometry(data[date_fields]), parse_esri_datetime)
    }else{
      data[date_fields] <-
        lapply(data[date_fields], parse_esri_datetime)
    }

    return(data)
  }
