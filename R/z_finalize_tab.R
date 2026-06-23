.finalize_tab = function(df1, aa = FALSE) {
  assert_that(is.data.frame(df1))

  txt = attr(df1, "title")
  txt = if (aa) {
    paste0(txt, " {", getOption('surveytable.survey_label'), " (age-adjusted)}")
  } else {
    paste0(txt, " {", getOption('surveytable.survey_label'), "}")
  }
  attr(df1, "title") = txt
  rownames(df1) = NULL
  class(df1) = c("astra_table", "data.frame")
  df1
}
