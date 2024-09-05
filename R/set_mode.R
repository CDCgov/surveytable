#' @rdname set_survey
#' @order 2
#' @export
set_mode = function(mode = "default") {
  opts.table = c("nchs", "default", "general")
  idx = mode %>% tolower %>% pmatch(opts.table)
  assert_that(noNA(idx), msg = paste("Unknown mode:", mode))
  opts = opts.table[idx]

  if (opts == "nchs") {
    message("* Mode: NCHS.")
    options(
      surveytable.tx_count = ".tx_count_1k"
      , surveytable.names_count = c("n", "Number (000)", "SE (000)", "LL (000)", "UL (000)")
      , surveytable.find_lpe = TRUE
      , surveytable.adjust_svyciprop = TRUE
    )
  } else if (opts %in% c("general", "default")) {
    message("* Mode: General.")
    options(
      surveytable.tx_count = ".tx_count_int"
      , surveytable.names_count = c("n", "Number", "SE", "LL", "UL")
      , surveytable.find_lpe = FALSE
      , surveytable.adjust_svyciprop = FALSE
    )
  } else {
    stop("!!")
  }

  invisible(NULL)
}
