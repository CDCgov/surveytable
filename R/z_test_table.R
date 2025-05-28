.test_table = function(rT, test_name, test_title, alpha, csv) {
  assert_that("p-value" %in% names(rT))
  bool.adj = ("p-adjusted" %in% names(rT))

  if (!getOption("surveytable.show_test_statistic")) {
    rT$`Test statistic` = NULL
    rT$`Degrees of freedom` = NULL
  }

  rT$Flag = ""
  idx = if (bool.adj) {
    which(rT$`p-adjusted` <= alpha)
  } else {
    which(rT$`p-value` <= alpha)
  }
  rT$Flag[idx] = "*"

  if (getOption("surveytable.do_tx")) {
    rT$`p-value` = getOption("surveytable.tx_pval") %>% do.call(list(rT$`p-value`))
    if (bool.adj) {
      rT$`p-adjusted` = getOption("surveytable.tx_pval") %>% do.call(list(rT$`p-adjusted`))
    }
  }

  attr(rT, "title") = test_title
  attr(rT, "footer") = paste0(test_name, ". *: p <= ", alpha)

  .write_out(rT, csv = csv)
}
