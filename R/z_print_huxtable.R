.as_object_huxtable = function(df1, ...) {
  assert_package("as_object", "huxtable")

  hh = huxtable::set_all_borders( huxtable::hux(df1) )
  if (!is.null(txt <- attr(df1, "title"))) {
    huxtable::caption(hh) = txt
  }
  if (!is.null(nc <- attr(df1, "num"))) {
    huxtable::number_format(hh)[-1,nc] = huxtable::fmt_pretty()
  }
  if (!is.null(txt <- attr(df1, "footer"))) {
    hh %<>% huxtable::add_footnote(txt)
  }
  hh
}

.print_huxtable = function(hh, destination = NULL, ...) {
  assert_package("print", "huxtable")
  dest = .get_destination(destination = destination)
  assert_that(dest != "latex"
              , msg = "Have not implemented LaTeX printing with huxtable yet. Try set_opts(output = 'kableExtra')")
  assert_that(dest %in% c("", "html"))

  if (dest == "") {
    gow = getOption("width")
    op_ = options(width = 10)
    on.exit(options(op_))
    huxtable::print_screen(hh, colnames = FALSE, min_width = 0
        , max_width = max(gow * 1.5, 150, na.rm = TRUE))
    cat("\n")
  } else {
    huxtable::print_html(hh)
  }
}

.get_destination = function(destination = NULL) {
  fo = ""
  if (!is.null(destination)) {
    fo = destination
  } else {
    # See huxtable::guess_knitr_output_format , huxtable:::assert_package
    if (requireNamespace("knitr", quietly = TRUE)
        && requireNamespace("rmarkdown", quietly = TRUE)) {
      fo = huxtable::guess_knitr_output_format()
    }
  }
  if ( !(fo %in% c("", "html", "latex")) ) fo = "html"
  assert_that(fo %in% c("", "html", "latex")
              , msg = glue("Unknown destination: '{fo}'"))
  fo
}
