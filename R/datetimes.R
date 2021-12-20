#' Convert Time Zones
#'
#' Convert the time zones of a layer to a specified TZ
#'
#' This function converts each datetime column to a specified timezone. This is a
#'  superficial conversion and doesn't actually change the moment of time, just the way it is
#'  displayed
#'
#' The function is neccessary because sf::st_read returns datetimes in a different TZ (GMT/BST)
#' to the API. So when returning cached data, you will get a different result to data from
#' the api.
#'
#' @param x a dataframe
#' @param tz the timezone to convert datetime columns to
#' @param dttm_fields a character vector of field names to convert to `tz`
#' @importFrom purrr map
#' @importFrom lubridate with_tz
convert_tz <-
  function(x, tz, dttm_fields){
    # map through the datetime columns & convert them to the specified TZ
    # Use with_tz as only need to change the way the dttm is displayed, not the moment of time
    x[,dttm_fields] <- purrr::map(dttm_fields, ~lubridate::with_tz(x[[.x]], tzone = tz))

    # Return the data
    return(x)
  }

#' Detect Datetime Fields
#'
#' Detect datetime fields which are present in a dataframe
#'
#' This function uses the layer_details object to determine which columns have the datetime type
#' and then only returns those which are present in the dataframe.
#'
#' @param x a dataframe from a query
#' @param layer_details the layer details object returned by `get_layer_details`
#' @return a character vector of field names which are present in x and have the type Datetime
#' @importFrom purrr map_chr
detect_dttm_fields <-
  function(x, layer_details){
   # Extract the field names to return
    # Can't get them from colnames(x) (as previous) as this causes an eror when there is a mismatch in order
    field_names <- purrr::map_chr(layer_details$fields, "name")

     # Detect the datetime fields and make a character vector of column names
    # Using a character vector instead of a logical vector allows mapping through
    # columns via x[[.x]] subsetting and this avoids the need to use
    # sf::st_drop_geometry which may cause issues if x is a tibble
    is_dttm <- purrr::map_chr(layer_details$fields, "type") == "esriFieldTypeDate"
    # Need to also check that the field is present in x otherwise any functions
    # which use the output of this function will fail when subsetting
    # since users have the option to only return a subset of columns
    col_in_x <- field_names %in% colnames(x)

    # Subset the columns to return datetime columns which are present in the data
    field_names[col_in_x & is_dttm]

  }

#' Parse Datetimes
#'
#' Parse Datetime variables
#'
#' @param data a dataframe / sf object returned by \code{get_geojson}
#' @param layer_details a list object returned by \code{get_layer_details}
#' @return a dataframe or sf object of the same structure as \code{data} but with datetime variables parsed
#' @importFrom purrr map_chr
#' @importFrom sf st_drop_geometry
parse_datetimes <-
  function(data, layer_details){

    dttm_fields <- detect_dttm_fields(x = data, layer_details = layer_details)


    # Don't run if no date fields to parse
    if(is.null(dttm_fields) || length(dttm_fields) == 0){
      return(data)
    }

    # Map through the date fields and parse the datetimes
    data[, dttm_fields] <-
      purrr::map(
        dttm_fields,
        ~ parse_esri_datetime(data[[.x]], tz = layer_timezone(layer_details))
      )

    return(data)
  }

#' Parse esri datetime
#'
#' Parse datetimes stored by esri
#'
#' @param x a vector of datetimes in the esri format
#' @param tz the timezone to return
#' @return a vector of datetimes
#' @importFrom lubridate date
#' @importFrom lubridate milliseconds
parse_esri_datetime <-
  function(x, tz){
    lubridate::as_datetime(as.numeric(x) * 0.001, tz = tz)
  }

#' Timezone
#'
#' Get the layers timezone for parsing
#'
#' @param layer_details the layer details object
#' @param default the default timezone - UTC
#' @return a string defining the timezone, either form the layer details or the default
layer_timezone <-
  function(layer_details, default = "UTC"){
    timezone <- layer_details$dateFieldsTimeReference$timeZone
    if(is.null(timezone)){return(default)}
    return(timezone)
  }
