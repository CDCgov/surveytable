.test_table = function(rT, test_name, test_title, alpha, csv) {
  assert_that("p-value" %in% names(rT))
  bool.adj = ("p-adjusted" %in% names(rT))

  rT$Flag = ""
  idx = if (bool.adj) {
    which(rT$`p-adjusted` <= alpha)
  } else {
    which(rT$`p-value` <= alpha)
  }
  rT$Flag[idx] = "*"

  rT$`p-value` %<>% round(3)
  if (bool.adj) {
    rT$`p-adjusted` %<>% round(3)
  }

  attr(rT, "title") = test_title
  attr(rT, "footer") = paste0(test_name, ". *: p <= ", alpha)

  .write_out(rT, csv = csv)
}
