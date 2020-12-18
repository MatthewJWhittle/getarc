test_that("modifying vectors works", {
  expect_equal(modify_named_vector(x = c(a = 1, b = 2),
                                   y = c(b = 3, c = 4)),
               c(a = 1, b = 3, c = 4)
               )
  expect_error(assert_that(
    1 == 2
  ), regexp = "1 == 2"
  )
  expect_error(assert_that(1 == 2,
                          message = "one does not equal two"),
               regexp = "one does not equal two")
  expect_error(assert_that(1 == 1), regexp = NA)
})

test_that("making empty tibbles works",
          {
            expect_equal(
              tibble(A = character(0), B = character(0)),
              make_empty_tibble(field_names = c("A", "B"), out_fields = "*")
            )

            expect_equal(
              tibble(A = character(0)),
              make_empty_tibble(field_names = c("A", "B"), out_fields = "A")
            )
          }
          )
