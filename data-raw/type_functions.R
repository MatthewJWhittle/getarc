type_functions <-
  tibble::tribble(~type, ~type_function, ~type_assert_function,
                  "esriFieldTypeBlob", NA, NA,
                  "esriFieldTypeDate", parse_iso8601_datetime, lubridate::is.POSIXct,
                  "esriFieldTypeDouble", as.double, is.double,
                  "esriFieldTypeGeometry", NA, NA,
                  "esriFieldTypeGlobalID", as.character, is.character,
                  "esriFieldTypeGUID", as.character,  is.character,
                  "esriFieldTypeInteger", as.integer,  is.integer,
                  "esriFieldTypeOID", as.integer, is.integer,
                  "esriFieldTypeRaster", NA, NA,
                  "esriFieldTypeSingle", as.integer, is.integer,
                  "esriFieldTypeSmallInteger", as.integer, is.integer,
                  "esriFieldTypeString", as.character, is.character,
                  "esriFieldTypeXML", as.character, is.character
  )

usethis::use_data(type_functions, overwrite = TRUE)
