#' Print surveytable tables
#'
#' @param x an object of class `surveytable_table` or `surveytable_list`.
#' @param ... ignored
#'
#' @return `x` invisibly.
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' table1 = tab("AGER")
#' print(table1)
#' table_many = tab("MDDO", "SPECCAT", "MSA")
#' print(table_many)
print.surveytable_table = function(x, ...) {
  df1 = x
  class(df1) = "data.frame"

  hh = df1 %>% hux %>% set_all_borders

  if (!is.null(txt <- attr(df1, "title"))) {
    if (isTRUE(nchar(txt) > getOption("width"))) {
      txt = paste(strwrap(txt), collapse = "\n")
    }
    caption(hh) = txt
  }

  if (!is.null(nc <- attr(df1, "num"))) {
    number_format(hh)[-1,nc] = fmt_pretty()
  }
  if (!is.null(txt <- attr(df1, "footer"))) {
    hh %<>% add_footnote(txt)
  }

  # See inside guess_knitr_output_format
  not_screen = (requireNamespace("knitr", quietly = TRUE)
                && requireNamespace("rmarkdown", quietly = TRUE)
                && guess_knitr_output_format() != "")

  if (not_screen) {
    hh %>% print_html
  } else {
    gow = getOption("width")
    op_ = options(width = 10)
    on.exit(options(op_))
    hh %>% print_screen(colnames = FALSE, min_width = 0, max_width = max(gow * 1.5, 150, na.rm=TRUE))
    cat("\n")
  }

  invisible(x)
}

#' @rdname print.surveytable_table
#' @export
print.surveytable_list = function(x, ...) {
  if (length(x) > 0) {
    for (ii in 1:length(x)) {
      print.surveytable_table(x[[ii]])
    }
  }
  invisible(x)
}
