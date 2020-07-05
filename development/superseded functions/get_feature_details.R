#' Get feature server details
#'
#' Download feature layer from a feature server
#'
#' @param host url for the ArcGIS Server host e.g 'https://services9.arcgis.com'
#' @param instance a string defining the ArcGIS Server instance
#' @param feature_server a string defining the name of the feature server
#' @param my_token an access token acquired via \code{get_token}
#'
#' @import httr
#' @import sf
#' @import purrr
#' @import dplyr
#' @importFrom magrittr %>%
#' @export get_feature_details
#'
#'
get_feature_details <-
  function(host,
           instance,
           feature_server,
           my_token = NULL) {
    #https://developers.arcgis.com/rest/services-reference/layer-feature-service-.htm


    rest <- "rest"
    services <- "services"
    server_type <- "FeatureServer"
    request_type <- "query"


    endpoint <-
      list(host,
           instance,
           "ArcGIS",
           rest,
           services,
           feature_server,
           server_type) %>% paste0(collapse = "/")

    f <- "json"

    # Get the token from the supplied acceess token
    if (!is.null(my_token)) {
      token <- parse_access_token(my_token)
    } else{
      token <- my_token
    }



    # Build a list of query parameters
    query <- list(f = f,
                  token = token)


    # Collapse the parameters into a string of length 1
    query_string <- collapse_query_parameters(query)


    # Request the data
    request <-
      httr::GET(paste0(endpoint, "?", query_string))

    # Fail on error
    stopifnot(httr::status_code(request) == 200)
    # Read the data from the temporary file

    feature_content <- jsonlite::fromJSON(content(request))

    sources <- c("layers", "tables")

    feature_tables <- feature_content[sources]

    feature_tables <-
      feature_tables %>% purrr::discard(~ length(.x) == 0)

    purrr::map2(feature_tables,
         .y = names(feature_tables),
         ~ .x %>% dplyr::mutate(data_type = .y)) %>%
      dplyr::bind_rows() %>% return()

  }
