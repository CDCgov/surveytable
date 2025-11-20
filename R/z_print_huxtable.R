.print_huxtable = function(df1, destination = NULL, ...) {
  ##
  if (inherits(df1, "surveytable_list")) {
    if (length(df1) > 0) {
      for (ii in 1:length(df1)) {
        Recall(df1 = df1[[ii]], destination = destination, ...)
      }
    }
    return(invisible(NULL))
  }

  ##
  assert_package("print", "huxtable")
  assert_that(inherits(df1, "surveytable_table"))
  dest = .get_destination(destination = destination)
  assert_that(dest != "latex"
              , msg = "Have not implemented LaTeX printing with huxtable yet. Try set_opts(output = 'kableExtra')")
  assert_that(dest %in% c("", "html"))

  ## Functions below might use as.data.frame() if the argument is not a data.frame,
  ## which creates unique column names, which is not what we want.
  class(df1) = "data.frame"

  ##
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

  ##
  if (dest == "") {
    gow = getOption("width")
    op_ = options(width = 10)
    on.exit(options(op_))
    huxtable::print_screen(hh, colnames = FALSE, min_width = 0
        , max_width = max(gow * 1.5, 150, na.rm = TRUE))
    cat("\n")
  } else if (dest == "html") {
    huxtable::print_html(hh)
  } else {
    stop("?")
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
