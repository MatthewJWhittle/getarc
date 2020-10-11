lookup <-
  list(
    esriGeometryPoint = c("POINT"),
    esriGeometryMultipoint = c("MULTIPOINT"),
    esriGeometryPolyline = c("LINESTRING", "MULTILINESTRING"),
    esriGeometryPolygon = c("POLYGON", "MULTIPOLYGON")
  )


esri_sf_type_lookup <-
  dplyr::bind_rows(purrr::map2(names(lookup),
                               lookup,
                               ~ tibble::tibble(esri = .x, sf = .y)))

usethis::use_data(esri_sf_type_lookup, overwrite = TRUE)
