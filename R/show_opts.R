#' @rdname set_opts
#' @export
show_opts = function() {
  # Reset
  # Mode

  adj = getOption("surveytable.svyciprop_adj")
  assert_that(adj %in% c("none", "nchs", "nhis"))
  if (adj == "none") {
    message("* Korn and Graubard confidence intervals for proportions.")
  } else if (adj == "nchs") {
    message("* Korn and Graubard confidence intervals for proportions with an adjustment that might be required by some (though not all) NCHS data systems.")
  } else if (adj == "nhis") {
    message("* Korn and Graubard confidence intervals for proportions with an adjustment that might be required by NHIS.")
  }

  xx = getOption("surveytable.output_print")
  assert_that(is.string(xx), nzchar(xx))
  switch(xx
         , ".print_huxtable" = "* Printing with huxtable."
         , ".print_gt" = "* Printing with gt."
         , ".print_kableextra" = "* Printing with kableExtra."
         , ".print_auto" = "* Printing with huxtable for screen, gt for HTML, or kableExtra for PDF."
         , ".print_raw" = "* Generating unformatted / raw output."
         , glue("Printing with a custom function: {xx}")) %>% message

  if (getOption("surveytable.raw")) {
    message("* To perform rounding, first turn off raw output.")
  } else {
    tx_count = getOption("surveytable.tx_count")
    assert_that(is.string(tx_count), nzchar(tx_count))
    switch(tx_count
           , ".tx_count_int" = "* Rounding counts to the nearest integer."
           , ".tx_count_1k" = "* Rounding counts to the nearest thousand."
           , ".tx_none" = "* Not rounding counts."
           , glue(" * Count rounding function: {tx_count}")) %>% message
  }

  lpe = getOption("surveytable.find_lpe")
  assert_that(is.flag(lpe), lpe %in% c(TRUE, FALSE))
  if (lpe) {
    message("* Identifying low-precision estimates.")
  } else {
    message("* Not identifying low-precision estimates.")
  }

  drop_na = getOption("surveytable.drop_na")
  assert_that(is.flag(drop_na), drop_na %in% c(TRUE, FALSE))
  if (drop_na) {
    message("* Dropping missing values. Showing knowns only.")
  } else {
    message("* Retaining missing values.")
  }

  max_levels = getOption("surveytable.max_levels")
  assert_that(is.count(max_levels))
  message(paste0("* Maximum number of levels is: ", max_levels))

  csv = getOption("surveytable.csv")
  assert_that(is.string(csv)
              , msg = "CSV file name must be a character string.")
  if (nzchar(csv)) {
    message(paste0("* Sending CSV output to: ", csv))
    if (file.exists(csv)) {
      message("* (File already exists. Output will be appended to the end of the file.)")
    }
    message("* To turn off CSV output: set_opts(csv = '')")
  } else {
    message("* CSV output has been turned off.")
  }

  invisible(NULL)
}
