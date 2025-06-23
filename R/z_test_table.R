.test_table = function(rT, test_name, test_title, alpha, csv) {
  assert_that("p-value" %in% names(rT))
  bool.adj = ("p-adjusted" %in% names(rT))

  # if (!getOption("surveytable.raw")) {
  #   rT$`Test statistic` = NULL
  #   rT$`Degrees of freedom` = NULL
  # }

  rT$Flag = ""
  idx = if (bool.adj) {
    which(rT$`p-adjusted` <= alpha)
  } else {
    which(rT$`p-value` <= alpha)
  }
  rT$Flag[idx] = "*"

  rT$`Test statistic` = getOption("surveytable.tx_test_stat") %>% do.call(list(rT$`Test statistic`))
  if ("Degrees of freedom" %in% names(rT)) {
    assert_that(!any(c("Degrees of freedom 1", "Degrees of freedom 2") %in% names(rT)))
    rT$`Degrees of freedom` = getOption("surveytable.tx_df") %>% do.call(list(rT$`Degrees of freedom`))
  } else {
    assert_that(all(c("Degrees of freedom 1", "Degrees of freedom 2") %in% names(rT)))
    rT$`Degrees of freedom 1` = getOption("surveytable.tx_df") %>% do.call(list(rT$`Degrees of freedom 1`))
    rT$`Degrees of freedom 2` = getOption("surveytable.tx_df") %>% do.call(list(rT$`Degrees of freedom 2`))
  }

  rT$`p-value` = getOption("surveytable.tx_pval") %>% do.call(list(rT$`p-value`))
  if (bool.adj) {
    rT$`p-adjusted` = getOption("surveytable.tx_pval") %>% do.call(list(rT$`p-adjusted`))
  }

  attr(rT, "title") = test_title
  attr(rT, "footer") = paste0(test_name, ". *: p <= ", alpha)

  .write_out(rT, csv = csv)
}
