# Make a list of new credentials to test against
credentials <- list(client_id = "my client id",
                    client_secret = "my client secret",
                    app_name = "my app name")

# Then set the new credentials
set_credentials(
  client_id = credentials$client_id,
  client_secret = credentials$client_secret,
  app_name = credentials$app_name,
  "~/secrets/test-getarc-credentials.json"
)

# Get the newly set credentials
new_credentials <- get_credentials(path = "~/secrets/test-getarc-credentials.json")

testthat::test_that("Getting and setting credentials works", {
  expect_type(new_credentials, "list")
  expect_equal(names(new_credentials), c("client_id", "client_secret", "app_name"))
  expect_equal(credentials, new_credentials)
})
