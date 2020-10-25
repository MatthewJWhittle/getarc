# Make a list of new credentials to test against
credentials <- list(client_id = "my client id",
                    client_secret = "my client secret",
                    app_name = "my app name")

# Get the credentials that are to be overwritten
# This allows the test to leave things as it found it
old_credentials <- get_credentials()

# Then set the new credentials
set_credentials(
  client_id = credentials$client_id,
  client_secret = credentials$client_secret,
  app_name = credentials$app_name
)

# Get the newly set credentials
new_credentials <- get_credentials()
# Return the credentials to their previous value
set_credentials(
  client_id = old_credentials$client_id,
  client_secret = old_credentials$client_secret,
  app_name = old_credentials$app_name
)

testthat::test_that("Getting and setting credentials works", {
  expect_type(new_credentials, "list")
  expect_equal(names(new_credentials), c("client_id", "client_secret", "app_name"))
  expect_equal(credentials, new_credentials)
})
