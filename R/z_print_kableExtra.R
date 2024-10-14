.as_object_kableextra = function(df1, destination = NULL, ...) {
  assert_package("as_object", "kableExtra")
  dest = .get_destination(destination = destination)
  assert_that(dest != "",
              msg = "Have not implemented screen printing with kableExtra yet. Try set_opts(output = 'huxtable')")
  assert_that(dest %in% c("html", "latex"))

  if (dest == "html") {
    hh = df1 %>% kableExtra::kbl(format = "html"
                      , caption = attr(df1, "title")
                      , table.attr = 'style = "caption-side: top;"'
                      , label = NA
                      , digits = Inf
                      , row.names = FALSE
                      , format.args = list(big.mark = ",")) %>%
      kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")
                                , full_width = FALSE, position = "left")
    if (!is.null(txt <- attr(df1, "footer"))) {
      hh %<>% kableExtra::footnote(general = txt, general_title = "")
    }
  } else if (dest == "latex") {
    hh = df1 %>% kableExtra::kbl(booktabs = TRUE
                      , format = "latex"
                      , caption = attr(df1, "title") %>% .latex_escape
                      , label = NA
                      , digits = Inf
                      , row.names = FALSE
                      , format.args = list(big.mark = ",")) %>%
      kableExtra::kable_styling(latex_options = c("striped", "HOLD_position", "scale_down")
                                , full_width = FALSE, position = "left")
    if (!is.null(ccs <- df1 %>% .kableExtra_column_spec)) {
      hh %<>% kableExtra::column_spec(column = ccs$column, width = ccs$width)
    }
    if (!is.null(txt <- attr(df1, "footer"))) {
      hh %<>% kableExtra::footnote(general = txt %>% .latex_escape, general_title = "")
    }
  }
  hh
}

.print_kableextra = function(hh, ...) {
  assert_package("print", "kableExtra")
  print(hh)
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

.kableExtra_column_spec = function(df1) {
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
