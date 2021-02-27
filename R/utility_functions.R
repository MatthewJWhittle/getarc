#' Lower Logical
#'
#' Convert a logical value to a lower case string
#'
#' This function converts TRUE or FALSE to the equivalent lower case string "true" or "false" for use in queries.
#' @param x logical vector
#' @return charactor vector
lower_logical <-
  function(x){
    stopifnot(is.logical(x))
    tolower(as.character(x))
  }
#' Modify vector
#'
#' Modify a vector using names
#'
#' This function combines two named vectors, replacing elements in x where their names have matches in y.
#' @param x a named vector to replace
#' @param y a named vector to combine with x
#' @return a named vector that is the combination of x and y, not containing any elements in x with matches in y
modify_named_vector <-
  function(x, y){
    x[names(y)] <- y
    return(x)
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
  function(endpoint){
    stopifnot(is.character(endpoint) && length(endpoint) == 1)
    stringr::str_detect(endpoint, "/MapServer/")
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
  function(content){
    is_error <- all(grepl("^\\{\"error", content))
    if(is_error){
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
  function(x, max_length){

    # Get the length of x and determine how many parts it should be split into
    # based upon the maximum allowed length. a ceiling is applied as parts must be
    # an integar and should always be rounded up
    x_length <- length(x)

    # Return the vector as a list if it doesn't exceed the maximum length
    # This will avoid any errors down the line
    if(x_length <= max_length){
      return(list(x))
    }

    parts <- ceiling(x_length / max_length)

    # create a sequence of the start of each vector
    starts <- seq(from = 1, to = x_length, by = max_length)

    # If the last element of the vector is the final element then it should be dropped
    if(utils::tail(starts, 1) == x_length){
      starts <- starts[c(1:(length(starts) - 1))]
      # If the start vector ends on the length then parts needs to be one less
      parts <- parts - 1
      }

    # Construct the ends of each part so that the parts don't overlap
    # The sequence should end on the length of x so it doesn't exceed the vector length
    # when indexing
    ends <- starts + (max_length - 1)
    ends[length(ends)] <- x_length

    # Make an empty list to fill with the indexed pars of x
    # This is more efficient & faster than incrementally increasing the
    # size of the vector
    x_split <- vector("list", length = parts)
    for(i in 1:parts){
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
#' @return a named character vector of length 1 to be included in query
where_in_query <-
  function(field, matching) {
    c(where = paste0(field, " IN ('",
                     paste0(matching, collapse = "', '"), "')"))
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
  function(field_names, out_fields){
    # If the user wants to only return certain fields, then filter the field names data
    if(all(out_fields != "*")){
      field_names <- field_names[field_names %in% out_fields]
    }
    # then make an empty tibble and fill it with empty columns which match the data
    empty_df <- tibble::tibble()
    for(field in field_names){
      empty_df[field] <- character(0)
    }
    return(empty_df)

  }
