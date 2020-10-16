dummy_data <-
  tibble(var1 = c(0, 1, NA, 2),
         var2 = c("a", "b", "c", "d"),
         var3 = c("a", "b", "c", "c")
         )

dummy_domains <-
  tibble(field_name = c(rep("var1", 3), rep("var3", 3)),
         name = c(c("desc1", "desc2", "desc3"),c("desc1", "desc2", "desc3")),
         code = as.character(c(c(0:2), c("a", "b", "c"))))


parse_coded_domains(data = dummy_data, domains = dummy_domains)

missing_domain_data <-
  tibble(var2 = c(1, 2, 3))

test_that("rep works", {
  expect_equal(
  parse_coded_domains(data = dummy_data,
                      domains = dummy_domains),
  tibble(var1 =  c("desc1", "desc2", NA, "desc3"),
         var2 = c("a", "b", "c", "d"),
         var3 = c("desc1", "desc2", "desc3", "desc3"))
  )
  expect_error(info = "doesn't error when domain missing",
               parse_coded_domains(missing_domain_data,
                                   dummy_domains),
               NA
               )
  expect_equal(info = "returns input object when domain missing",
               parse_coded_domains(missing_domain_data,
                                   dummy_domains),
               missing_domain_data
  )
})
