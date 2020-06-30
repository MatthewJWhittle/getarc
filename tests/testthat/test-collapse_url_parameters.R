x_null <- list(a = 1,
               b = 2,
               layer_id = NULL,
               d = 5)

x <- list(a = 1,
          b = 2,
          layer_id = 1,
          d = 5)
test_that("collapse url works", {
  expect_warning(collapse_url_parameters(x_null, drop_null = FALSE))
  expect_equal(collapse_url_parameters(x_null, drop_null = T), "1/2/5")
})
