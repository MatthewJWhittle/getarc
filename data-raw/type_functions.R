type_functions <-
  tibble::tribble(~type, ~type_function,
                  "esriFieldTypeBlob", NA,
                  "esriFieldTypeDate", as.POSIXct,
                  "esriFieldTypeDouble", as.double,
                  "esriFieldTypeGeometry", NA,
                  "esriFieldTypeGlobalID", as.character,
                  "esriFieldTypeGUID", as.character,
                  "esriFieldTypeInteger", as.integer,
                  "esriFieldTypeOID", as.integer,
                  "esriFieldTypeRaster", NA,
                  "esriFieldTypeSingle", as.integer,
                  "esriFieldTypeSmallInteger", as.integer,
                  "esriFieldTypeString", as.character,
                  "esriFieldTypeXML", as.character
  )

usethis::use_data(type_functions, overwrite = TRUE)
