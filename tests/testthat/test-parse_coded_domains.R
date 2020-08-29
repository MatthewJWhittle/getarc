dummy_data <-
  tibble(var1 = c(0, 1, NA, 2),
         var2 = c("a", "b", "c", "d")
         )
dummy_domains <-
  tibble(field_name = rep("var1", 3),
         name = c("desc1", "desc2", "desc3"),
         code = c(0:2))

parse_coded_domains(data = dummy_data, domains = dummy_domains)

test_that("rep works", {
  expect_equal(
  parse_coded_domains(data = dummy_data,
                      domains = dummy_domains),
  tibble(var1 =  c("desc1", "desc2", NA, "desc3"),
         var2 = c("a", "b", "c", "d"))
  )
})
