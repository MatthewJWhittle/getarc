lookup <-
  list(
    esriGeometryPoint = c("POINT"),
    esriGeometryMultipoint = c("MULTIPOINT"),
    esriGeometryPolyline = c("LINESTRING", "MULTILINESTRING"),
    esriGeometryPolygon = c("POLYGON", "MULTIPOLYGON")
  )

esri_sf_type_lookup <-
  tibble::tibble(
  esri = c(
    "esriGeometryPoint",
    "esriGeometryMultipoint",
    "esriGeometryPolyline",
    "esriGeometryPolyline",
    "esriGeometryPolygon",
    "esriGeometryPolygon"
  ),
  sf = c(
    "POINT",
    "MULTIPOINT",
    "LINESTRING",
    "MULTILINESTRING",
    "POLYGON",
    "MULTIPOLYGON"
  ),
  json = c("point", "points",
           "paths", "paths",
           "rings", "rings")
)


# esri_sf_type_lookup <-
#   dplyr::bind_rows(purrr::map2(names(lookup),
#                                lookup,
#                                ~ tibble::tibble(esri = .x, sf = .y)))

usethis::use_data(esri_sf_type_lookup, overwrite = TRUE)
