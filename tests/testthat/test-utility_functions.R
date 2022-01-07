test_that("assert that works", {
  expect_error(assert_that(1 == 2), regexp = "1 == 2")
  expect_error(assert_that(1 == 2,
                           message = "one does not equal two"),
               regexp = "one does not equal two")
  expect_error(assert_that(1 == 1), regexp = NA)
})


x <- sample(c(1:100), replace = TRUE, size = 100)
max_length <- 9

split_1001_2 <- split_vector(x = c(1:1001),
             max_length = 1000)

test_that("splitting a vector works",
          {
            # Length should not exceed max length
            expect_true(max_length >= length(split_vector(x,
                                             max_length = max_length)[[1]]))

            # unlisted output should be the same as input vector
            expect_equal(x,
                         unlist(split_vector(x, max_length = max_length)))

            # It should return a list
            expect_type(split_vector(x, max_length = max_length), "list")
            # This should be split into two parts
            expect_equal(length(split_1001_2), 2)

            expect_equal(length(split_vector(c(1:100), max_length = 10)), 10)
            expect_equal(length(split_vector(c(9:132), max_length = 10)), 13)
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

