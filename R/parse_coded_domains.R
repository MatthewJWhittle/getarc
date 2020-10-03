#' Parse Coded Domains
#'
#' Replace the coded domain values with their descriptive values
#'
#' @param data a dataframe / sf object returned by \code{get_goejson}
#' @param domains a dataframe of domains and the descriptive and coded values returned by \code{domain_lookup}
#' @return an sf object with coded domain values exchanged for their coded values
#' @importFrom dplyr left_join
#' @importFrom dplyr filter
#' @importFrom dplyr select

parse_coded_domains <-
  function(data, domains) {


    # prefix column names with "." to avoid any conflicts with names in the data
    colnames(domains) <- paste0(".", colnames(domains))

    # Get the column names to ensure the data is outputted in the same format
    data_cols <- colnames(data)

    # When there is a restricted set of columns in data this function
    # throws an error by looking for domains that aren't present.
    # The purpose of the code below is to drop any missing domains from the table
    # Then if none are left the function returns data un altered
    domains <- domains[domains$.field_name %in% data_cols, ]


    # If there are no domains then return the data without any alterations
    if(nrow(domains) == 0){
      return(data)
    }

    loop_data <- data

    for (field in unique(domains$.field_name)) {
      # Construct a named vector to use in left_join
      # This enables the vector name to be generated for
      # each field name as c(field = ".code") won't work
      key <- c(".code")
      names(key) <- field

      loop_data <-
        loop_data %>%
        dplyr::left_join(
          domains %>%
            dplyr::filter(.data$.field_name == field) %>%
            dplyr::select(.data$.name, .data$.code),
          by = key
        ) %>% dplyr::select(-field)

      colnames(loop_data)[colnames(loop_data) == ".name"] <- field

    }

    loop_data <-
      loop_data %>%
      dplyr::select(data_cols)

    return(loop_data)
  }
