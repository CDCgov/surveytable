#' Print surveytable tables
#'
#' @param x an object of class `surveytable_table` or `surveytable_list`.
#' @param .output output type. `NULL` = auto-detect.
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
print.surveytable_table = function(x, .output = NULL, ...) {
  df1 = x
  class(df1) = "data.frame"

  # See inside guess_knitr_output_format
  fo = ""
  if (!is.null(.output)) {
    fo = .output
  } else {
    if (requireNamespace("knitr", quietly = TRUE)
        && requireNamespace("rmarkdown", quietly = TRUE)) {
      fo = guess_knitr_output_format()
    }
  }

  if (fo == "latex") {
    hh = df1 %>%
      kbl(booktabs = TRUE
        , format = "latex"
        , caption = attr(df1, "title") %>% .latex_escape
        , label = NA
        , digits = Inf
        , row.names = FALSE
        , format.args = list(big.mark = ",")
        ) %>%
      kable_styling(latex_options = c("striped"
        , "HOLD_position"
        , "scale_down"
        )
        , position = "left"
        )
    if (!is.null(ccs <- df1 %>% .calc_column_spec)) {
      hh %<>% column_spec(
        column = ccs$column
        , width = ccs$width
      )
    }
    if (!is.null(txt <- attr(df1, "footer"))) {
      hh %<>% footnote(general = txt %>% .latex_escape
                       , general_title = "")
    }
    hh %>% print

    return( invisible(x) )
  }

  hh = df1 %>% hux %>% set_all_borders
  if (!is.null(txt <- attr(df1, "title"))) {
    # caption(hh) = paste(strwrap(txt), collapse = "\n")
    caption(hh) = txt
  }
  if (!is.null(nc <- attr(df1, "num"))) {
    number_format(hh)[-1,nc] = fmt_pretty()
  }
  if (!is.null(txt <- attr(df1, "footer"))) {
    hh %<>% add_footnote(txt)
  }

  if (fo == "") {
    gow = getOption("width")
    op_ = options(width = 10)
    on.exit(options(op_))
    hh %>% print_screen(colnames = FALSE, min_width = 0
                        , max_width = max(gow * 1.5, 150, na.rm = TRUE))
    cat("\n")
  } else {
    hh %>% print_html
  }

  invisible(x)
}

.latex_escape = function(xx) {
  if (is.null(xx) || !is.character(xx)) return(xx)

  # https://tex.stackexchange.com/questions/34580/escape-character-in-latex

  # must come first:
  xx = gsub("\\", "\\textbackslash", xx, fixed = TRUE)

  for (cc in c("&", "%", "$", "#", "_", "{", "}")) {
    rep = paste0("\\", cc)
    xx = gsub(cc, rep, xx, fixed = TRUE)
  }
  xx = gsub("~", "\\textasciitilde", xx, fixed = TRUE)
  xx = gsub("^", "\\textasciicircum", xx, fixed = TRUE)

  xx
}

.calc_column_spec = function(df1) {
  n.nch = df1 %>% names %>% nchar
  c.nch = df1 %>% sapply(function(x) x %>% nchar %>% max(na.rm = TRUE) )
  nch = pmax(n.nch, c.nch, na.rm = TRUE)
  idx = which(nch > 15)

  lidx = length(idx)
  if (lidx > 0 && lidx <= 11) {
    n1 = nch[idx]
    if (sum(n1) > 50) {
      n1 = round(50 * n1 / sum(n1)) %>% pmax(10)
    }
    ww = paste0(n1, "ex")
    return( list(column = idx, width = ww) )
  }
  return(NULL)
}


#' @rdname print.surveytable_table
#' @export
print.surveytable_list = function(x, .output = NULL, ...) {
  if (length(x) > 0) {
    for (ii in 1:length(x)) {
      print.surveytable_table(x[[ii]], .output = .output)
    }
  }
  invisible(x)
}
