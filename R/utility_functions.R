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
#' @importFrom rlang expr_text
#' @return NULL
assert_that <-
  function(expr, message = NULL) {
    if (!expr) {
      if (is.null(message)) {
        message <-
          paste0(rlang::expr_text(substitute(expr)), " is not TRUE")
      }
      stop(message,
           call. = FALSE)
    }
  }
