
test_that("return standard attr", {
  expect_equal(
    query_string(f = "json", outSR = 4326, returnIdsOnly = "false", where = "1=1",
                 outFields = "*", returnCountOnly = "false"
                 ),
    "?f=json&outSR=4326&returnIdsOnly=false&where=1=1&outFields=*&returnCountOnly=false"
  )
  expect_equal(
    # Overwrite default where clause parameter
    query_string(),
    "?f=json"
  )
  expect_equal(
    # Add parameters
    query_string(geometry = "-1.13688299820441,54.4203321946811,-1.13380111202729,54.4221293935644"),
    "?f=json&geometry=-1.13688299820441,54.4203321946811,-1.13380111202729,54.4221293935644"
  )
  # list flattening works
  expect_equal(
    query_string(param1 = 1, param2 = 2, more_params = list(more_params1 = 1, more_params2 = 2)),
    "?f=json&param1=1&param2=2&more_params1=1&more_params2=2"
  )
  expect_equal(
    query_string(param1 = 1, param2 = 2, more_params = c(more_params1 = 1, more_params2 = 2)),
    "?f=json&param1=1&param2=2&more_params1=1&more_params2=2"
  )

})
