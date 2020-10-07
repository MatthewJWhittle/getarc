test_that("modifying vectors works", {
  expect_equal(modify_named_vector(x = c(a = 1, b = 2),
                                   y = c(b = 3, c = 4)),
               c(a = 1, b = 3, c = 4)
               )
})
