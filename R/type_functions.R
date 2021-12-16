#' Type Functions
#'
#' The function used to assert a variable matches the type returned by ESRI
#'
#' st_read doesn't always return the right data type (e.g. if the variable is all NA) and
#' this causes issues when combining data. This table is used in the parse_types function
#' to parse each variable in a data frame to the correst type
"type_functions"
