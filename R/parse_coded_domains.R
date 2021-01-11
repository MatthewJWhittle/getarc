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
#' @importFrom dplyr mutate
#' @importFrom dplyr if_else
#' @importFrom purrr map_df

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

    for (.field in unique(domains$.field_name)) {
      # Construct a named vector to use in left_join
      # This enables the vector name to be generated for
      # each field name as c(field = ".code") won't work
      key <- c(".code")
      names(key) <- .field
      # Get the variable type for 'parsing'
      type <- typeof(unlist(loop_data[names(key)]))

      loop_data <-
        loop_data %>%
        dplyr::left_join(
          domains %>%
            dplyr::filter(.data$.field_name == .field) %>%
            dplyr::select(.data$.name, .data$.code) %>%
            # domain table is character type because domains codes can be
            # integar or character. but type must match that of df column
            # Parse the domain codes to the right type so that left_join works
            dplyr::mutate(.code = as_type(.data$.code, type = type)
                          ),
          by = key
        ) %>%
        # If a domain hasn't been coded up correctly, then entries that don't fit the domain will be dropped
        # This is is not desirable because we always want the entered value, even if it doesn't match the domain
        # This code checks for missing values after joining the domain values & replaces them with their
        # original values
        dplyr::mutate(.name = dplyr::if_else(is.na(.name),
                                             # The !! evaluates .field (because it is only a string, not a column in the data)
                                             # Need to assert that the type of 'true' is the same as false
                                             true = as_type(get(.field), typeof(.name)),
                                             false = .name)) %>%
        dplyr::select(-.field)

      # Finally rename the field to its original value
      colnames(loop_data)[colnames(loop_data) == ".name"] <- .field

    }

    loop_data <-
      loop_data %>%
      dplyr::select(data_cols)

    return(loop_data)
  }
