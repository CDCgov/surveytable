.test_table = function(rT, test_name, test_title, alpha, csv) {
  assert_that("p-value" %in% names(rT))

  rT$Flag = ""
  idx = which(rT$`p-value` <= alpha)
  rT$Flag[idx] = "*"

  rT$`p-value` %<>% round(3)

  attr(rT, "title") = test_title
  attr(rT, "footer") = paste0(test_name, ". *: p-value <= ", alpha)

  .write_out(rT, csv = csv)
}
