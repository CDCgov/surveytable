.print_gt = function(df1, destination = NULL, ...) {
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
  assert_package("print", "gt")
  assert_that(inherits(df1, "surveytable_table"))
  dest = .get_destination(destination = destination)
  assert_that(dest != "latex",
              msg = "Have not implemented LaTeX printing with gt yet. Try set_opts(output = 'kableExtra')")
  assert_that(dest %in% c("", "html"))

  ##
  ## Functions below might use as.data.frame() if the argument is not a data.frame,
  ## which creates unique column names, which is not what we want.
  class(df1) = "data.frame"

  ##
  ## Non-unique names fix
  nn0 = names(df1)
  nn1 = nn0 %>% make.names(unique = TRUE)
  names(df1) = nn1

  hh = gt::opt_stylize(gt::gt(df1))
  hh = gt::cols_label_with(hh, fn = function(v1) {
    idx = which(nn1 == v1)
    assert_that(length(idx) == 1)
    nn0[idx]
  })

  if (!is.null(txt <- attr(df1, "title"))) {
    hh = gt::tab_header(hh, title = txt)
  }
  if (!is.null(nc <- attr(df1, "num"))) {
    hh = gt::fmt_integer(hh, columns = nc)
  }
  if (!is.null(txt <- attr(df1, "footer"))) {
    hh = gt::tab_footnote(hh, footnote = txt, placement = "left")
  }

  ##
  if (dest == "") {
    print(hh)
  } else if (dest == "html") {
    print(gt::as_raw_html(hh))
  } else {
    stop("?")
  }
}
