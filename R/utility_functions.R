#' Lower Logical
#'
#' Convert a logical value to a lower case string
#'
#' This function converts TRUE or FALSE to the equivalent lower case string "true" or "false" for use in queries.
#' @param x logical vector
#' @return charactor vector
lower_logical <-
  function(x) {
    stopifnot(is.logical(x))
    tolower(as.character(x))
  }
#' Map Server
#'
#' Is an endpoint a map server
#'
#' Feature & Map servers have different formats of querying and data. This function checks an endpoint string and returns TRUE or FALSE.
#' @param endpoint a string defining an esri endpoint
#' @return TRUE or FALSE
#' @importFrom stringr str_detect
map_server <-
  function(endpoint) {
    stopifnot(is.character(endpoint) && length(endpoint) == 1)
    grepl("/MapServer/", endpoint)
  }
#' As Type
#'
#' Convert a vector to a specific type
#'
#' This function is used to convert a vector to a specific type, for instance where variables need to match types in joins.
#' @param x a vector
#' @param type the type to convert the vector to
#' @return a vector of with the values of `x` and the same type as `type`
# type <- "integer"
# x <- as.character(c(1:10))
as_type <-
  function(x, type) {
    # Make a list of parsing functions to index
    parse <-
      list(
        double = as.double,
        character = as.character,
        logical = as.logical,
        integer = as.integer
      )

    stopifnot(type %in% names(parse))

    parse[[type]](x)
  }

#' Assert That
#'
#' Fail and inform
#'
#' @param expr an R expression
#' @param message the message to print if `expr` evaluates to `FALSE`. If NULL, the expression is printed like in stopifnot
#' @return NULL
assert_that <-
  function(expr, message = NULL) {
    if (!expr) {
      if (is.null(message)) {
        message <-
          paste0(deparse(substitute(expr)), " is not TRUE")
      }
      stop(message,
           call. = FALSE)
    }
  }
#' Check ESRI error
#'
#' Checks for an esri error and returns it
#' @param content the content of a response
#' @return null
check_esri_error <-
  function(content) {
    is_error <- !is.null(names(content)) && names(content)[1] == "error"
    if (is_error) {
      stop(content)
    }
  }

#' Split a Vector
#'
#' Split a Vector
#'
#' This function splits a vector so that it doesn't exceed a maximum length
#'
#' @param x a vector
#' @param max_length the maximum length of the returned vectors
#' @return a list of split x where each element does not exceed the length of max_length
#' @importFrom utils tail
split_vector <-
  function(x, max_length) {
    # Get the length of x and determine how many parts it should be split into
    # based upon the maximum allowed length. a ceiling is applied as parts must be
    # an integar and should always be rounded up
    x_length <- length(x)

    # Return the vector as a list if it doesn't exceed the maximum length
    # This will avoid any errors down the line
    if (x_length <= max_length) {
      return(list(x))
    }

    parts <- ceiling(x_length / max_length)

    # create a sequence of the start of each vector
    starts <- seq(from = 1, to = x_length, by = max_length)

    ## This was causing errors with a vector 1 element longer than max length returning parts -1
    # # If the last element of the vector is the final element then it should be dropped
    # if (utils::tail(starts, 1) == x_length) {
    #   starts <- starts[c(1:(length(starts) - 1))]
    #   # If the start vector ends on the length then parts needs to be one less
    #   parts <- parts - 1
    # }

    # Construct the ends of each part so that the parts don't overlap
    # The sequence should end on the length of x so it doesn't exceed the vector length
    # when indexing
    ends <- starts + (max_length - 1)
    ends[length(ends)] <- x_length

    # Make an empty list to fill with the indexed pars of x
    # This is more efficient & faster than incrementally increasing the
    # size of the vector
    x_split <- vector("list", length = parts)
    for (i in 1:parts) {
      x_split[[i]] <- x[c(starts[i]:ends[i])]
    }

    return(x_split)
  }

#' Where In Query
#'
#' Construct a where in query
#'
#' Construct a where in query to se for getting FIDs
#'
#' @param field which field should match `matching`
#' @param matching which elements of `field` should be returned
#' @param named should a named vector e.g. c(where = "...") be returned or just the query string
#' @return a named character vector of length 1 to be included in query
where_in_query <-
  function(field, matching, named = FALSE) {
    # Avoid scientific notation
    if (is.numeric(matching)) {
      matching <- as.character(format(matching, scientific = FALSE, trim = TRUE))
    }

    query <-
      paste0(field, " IN ('",
             paste0(matching, collapse = "', '"), "')")

    if (named) {
      return(list(where = query))
    }

    return(query)
  }

#' Make Empty Tibble
#'
#' Make an empty tibble with specified column names
#'
#' This function makes an empty tibble with specified column names
#'
#' @param field_names the names of the columns to include
#' @param out_fields the fields to filter from the field_names if user has specified wanting certain fields
#' @importFrom tibble tibble
#' @return an emtpy tibble with the names in out_fields
make_empty_tibble <-
  function(field_names, out_fields) {
    # If the user wants to only return certain fields, then filter the field names data
    if (all(out_fields != "*")) {
      field_names <- field_names[field_names %in% out_fields]
    }
    # then make an empty tibble and fill it with empty columns which match the data
    empty_df <- tibble::tibble()
    for (field in field_names) {
      empty_df[field] <- character(0)
    }
    return(empty_df)

  }

#' Parse R JSON
#'
#' Parse a httr response using rjson
#'
#' This function implements faster json parsing the jsonlite and httr
#' This would be slightly faster with jsonify for large json objects but it is only a minimal performance increase
#' @param response a response object returned by a GET or POST request
#' @return an R object of parsed json
#' @importFrom httr content
#' @importFrom rjson fromJSON
parse_rjson <- function(response) {
  # This would be slightly faster with jsonify::from_json for large json objects but it is only a minimal performance increase
  rjson::fromJSON(httr::content(response, as = "text"))
}

#' Add a point to EP
#'
#' Add a test point to the points endpoint
#'
#' This function is used for testing layer caching & demonstrates how to add features to an arc gis layer
#' @param endpoint the points endpoint to test against
#' @param x the x coordinate of the point (EPSG:4326)
#' @param y the y coordinate of the point (EPSG:4326)
#' @param id an integar to give the point an ID (not unique)
#' @param attributes the attributes of the point (a named list)
#' @return the status code of the response (integar)
#' @importFrom stats rnorm
#' @importFrom  rjson toJSON
add_point_to_test_ep <-
  function(endpoint,
           x = rnorm(mean = 53.317749,
                     sd = 1,
                     n = 1),
           y = rnorm(mean = -1.0546875,
                     sd = 1,
                     n = 1),
           attributes = list(id = sample(c(1:1000), 1))
           ) {


    attributes_json <- rjson::toJSON(attributes)

    features <-
      glue::glue(
        '[
            {
              "geometry" : {"x" : (x), "y" : (y)},
              "attributes" : (attributes_json)
            }
          ]',
        .open = "(",
        .close = ")"
      )



    response <-
      httr::POST(
        url = glue::glue("{endpoint}/addFeatures"),
        body = list(f = "json",
                    features = features)
      )

    return(response$status_code)

  }


#' Replace NULLS
#'
#' Replace NULL values with a supplied value
#'
#' This function is a helper to replace null values returned by the API with a specified values. This is NA by default.
#' @param x a vector possibly containing nulls
#' @param with what to replace the nulls with, default is NA
#' @return a vector of equal length to x which will not contain null values but the value of with instead
replace_null <-
  function(x, with = NA) {
    null_values <- is.null(x)
    if (all(!null_values)) {
      return(x)
    }
    x[null_values] <- NA
    return(x)
  }
#' Get ID field
#'
#' Get the unique ID field from the layer details
#'
#' MapServers and Feature Servers encode the unique id field differently. This function uses two methods to retrieve the ID field from the layer details. Unique IDs are used for caching.
#' @param endpoint the layer endpoint
#' @param layer_details the layer details object returned by get_layer_details.
#' @return a string defining the field that encodes the unique IDs
get_unique_id_field <-
  function(endpoint, layer_details) {
    # MapServers and Feature Servers encode the unique id field differently
    # This function uses two methods to retieve the ID field from the layer details
    # If the endpoint is a map server then the unique ID field should be retrieved from
    # the layer details.
    if (map_server(endpoint)) {
      id_field <-
        purrr::map_lgl(layer_details$fields,
                       ~ .x[["type"]] == "esriFieldTypeOID")
      return(layer_details$fields[id_field][[1]]$name)
    }
    # Otherwise, return the id field
    return(layer_details$uniqueIdField$name)
  }
#' Caching Method
#'
#' Which caching method should be used based on how edits are tracked
#'
#' Some layers don't support edit tracing and can't be cached. This function checks whether it is supported.
#' @param layer_details the layer details object returned be get_layer_details.
#' @return either "layer_edit" for tracking edits to the layer as a whole, "feature_edits" for tracking edits to individual features or NULL for no caching due to lack of edit tracking
cache_method <-
  function(layer_details) {
    last_edit = !is.null(layer_details$editingInfo$lastEditDate)
    feature_edit_tracking = !is.null(layer_details$editFieldsInfo$editDateField)

    # Return the method of caching to use
    if (feature_edit_tracking) {
      return("feature_edit")
    }
    if (last_edit) {
      return("layer_edit")
    }
    return(NULL)
  }

#' Drop NULL
#'
#' Drop NULL values from a list
#'
#' @param x a list
#' @return a list without any null values
drop_null <-
  function(x) {
    x[!unlist(lapply(x, is.null))]
  }
#' Query Object
#'
#' Compose a Query Object
#'
#' This function composes a query object from a set of query parameters that are either default, mandatory or user specified.
#' @param default the default query parameters such as return format and crs (list).
#' @param user_query the user query passed into the query argument or as argument params (list).
#' @param mandatory the mandatory query parameters (list).
#' @param my_token the access token if required.
#' @return a list of query parameters to pass as the post body in a request
query_object <-
  function(default = default_query_parameters(),
           user_query = list(),
           mandatory = list(),
           my_token = NULL) {
    # Check Arguments
    stopifnot(is.list(default))
    stopifnot(is.list(user_query))
    stopifnot(is.list(mandatory))

    # Parse the access token
    token <- parse_access_token(my_token = my_token)

    # Combine the query sequentially, favouring user specified arguments over
    # the default params, but ensuring mandatory ones are included
    # Only keep default if they haven't already been specified
    query <-
      utils::modifyList(default, user_query, keep.null = FALSE)
    # Always keep user params & defaults unless they should be overridden by the default
    query <- utils::modifyList(query, mandatory, keep.null = FALSE)
    # Add in the token
    query <-
      utils::modifyList(query, list(token = token), keep.null = FALSE)

    return(query)
           }
#' Field Names
#'
#' Get the field names from layer details
#'
#' @param layer_details the layer_details object
#' @return a character vector of field names
#' @importFrom purrr map_chr
field_names <-
  function(layer_details){
    purrr::map_chr(layer_details$fields, "name")
  }

#' Parse Types
#'
#' Parse column types
#'
#' Parse the tibbles column types using the layer details obect to define them
#' @param  x the dataframe to parse
#' @param layer_details the layer details object
#' @importFrom purrr map_chr
#' @importFrom purrr map2
#' @importFrom dplyr left_join
#' @importFrom dplyr filter
#' @importFrom sf st_drop_geometry
#' @return a dataframe like x but with variabes matching the specified types
parse_types <-
  function(x, layer_details) {

    # Make a table of the field types from the layer details
    field_types <-
      tibble::tibble(
        name = purrr::map_chr(layer_details$fields, "name"),
        type = purrr::map_chr(layer_details$fields, "type")
      )

    # Drop any columns not present in the dataframe
    # Avoids errors when only returing asubset of columns
    field_types <- dplyr::filter(field_types, .data$name %in% colnames(x))

    # Join in the functions which parse each field type
    field_types <- dplyr::left_join(field_types, type_functions, by = "type")

    # Add in the timezone argument for datetime so that when dttms are parsed
    # they are in the right timezone. This needs to be done once the data is downloaded
    # Because that is when the expected TZ is known
    is_dttm <- type_functions$type == "esriFieldTypeDate"
    dttm_function <- type_functions$type_function[[which(is_dttm)]]
    type_functions$type_function[[which(is_dttm)]] <- purrr::partial(dttm_function,
                                                                     tz = layer_timezone(layer_details))

    # function to check sf
    is_sf <- function(x){any(c("sf", "sfc") %in% class(x))}
    # only drop geom if sf
    if (is_sf(x)) {
      x_to_parse <- sf::st_drop_geometry(x)
    } else{
      x_to_parse <- x
    }

    modifyList(x,
               purrr::map2(
                 .x = x_to_parse[field_types$name],
                 .y = field_types$type_function,
                 ~ .y(.x)
               ))
  }
#' Detect Tables
#'
#' Is the endpoint a table
#'
#' This function finds out if the layer is a table from the layer_details
#'
#' @param layer_details the layer details object returnd by get_layer_details
#' @return TRUE/FALSE
is_table <- function(layer_details){layer_details$type == "Table"}
#' Write sf as GEOJSON
#'
#' Write a GeoJSON file
#'
#' This function takes an sf object and writes it to a specified filepath as geojson
#' This is a faster alternative to sf::st_write
#' @param sf an sf object to be written to disk
#' @param filepath the filepath of the sf object
#' @importFrom geojsonsf sf_geojson
#' @return NULL
sf_geojson_write <-
  function(sf, filepath) {
    # First convert dates to character
    # Writing datetimes strips out the timezone and causes mismatches between
    # data from the API and disk. This properly formats them to iso8601
    sf <- convert_datetimes_to_iso8601(sf)
    # Convert the sf object to a geojson file
    geojson <- geojsonsf::sf_geojson(sf)
    # Writing to disk
    # Open a file connetion & write the lines of the geojson string
    connection <- file(filepath)
    writeLines(geojson, connection)
    # Close the file connetion
    close(connection)
  }

#' ObjectID Query
#'
#' Generate an object ID query to get data
#'
#' This function takes object IDs and properly formats a query parameter based on whether the service
#' is a map server or feature server. For Map Servers the query should be in the form objectIds=1,2,3
#' and for Feature Servers the query should be where=ObjectId IN ('1', '2', ...)
#' @param object_id_name the field name for object ids
#' @param object_ids a numeric vector of object IDs
#' @param map_server TRUE/FALSE is the service a map server
#' @return a list with one named character element
id_query <-
  function(object_id_name, object_ids, map_server){

  object_ids <- as.character(format(object_ids, scientific = FALSE, trim = TRUE))

  if(map_server){
    parameter <- list(objectIds = paste0(object_ids, collapse = ","))
  }else{
    parameter <- where_in_query(field = object_id_name, matching = object_ids, named = TRUE)
  }
    return(parameter)

}
