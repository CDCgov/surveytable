.finalize_tab = function(df1) {
  assert_that(is.data.frame(df1))

  txt = attr(df1, "title")
  txt = paste0(txt, " {", getOption('surveytable.survey_label'), "}")
  attr(df1, "title") = txt
  rownames(df1) = NULL
  class(df1) = c("surveytable_table", "data.frame")
  df1
}
