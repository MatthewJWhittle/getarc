load_all()
test_that("return standard attr", {
  expect_equal(
    query_string(query = NULL),
    "query?f=json&where=1=1&outSR=4326&returnIdsOnly=false&outFields=*&returnCountOnly=false"
  )
  expect_equal(
    # Overwrite default where clause parameter
    query_string(query = list("where" = "2=2")),
    "query?f=json&outSR=4326&returnIdsOnly=false&outFields=*&returnCountOnly=false&where=2=2"
  )
  expect_equal(
    # Add parameters
    query_string(query = list(geometry = "-1.13688299820441,54.4203321946811,-1.13380111202729,54.4221293935644")),
    "query?f=json&outSR=4326&returnIdsOnly=false&where=1=1&outFields=*&returnCountOnly=false&geometry=-1.13688299820441,54.4203321946811,-1.13380111202729,54.4221293935644"

  )

})
