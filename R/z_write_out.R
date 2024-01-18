.write_out = function(df1, csv) {
  assert_that(is.data.frame(df1))

  txt = attr(df1, "title")
  txt %<>% paste0(" {", getOption("surveytable.survey_label"), "}")
  attr(df1, "title") = txt

	if (nzchar(csv)) {
	  if (!is.null(txt <- attr(df1, "title"))) {
	    write.table(txt, file = csv
	                , append = TRUE, row.names = FALSE
	                , col.names = FALSE
	                , sep = ",", qmethod = "double") %>% suppressWarnings
	  }
	  write.table(df1, file = csv
	              , append = TRUE, row.names = FALSE
	              , sep = ",", qmethod = "double") %>% suppressWarnings
	  if (!is.null(txt <- attr(df1, "footer"))) {
	    write.table(txt, file = csv
	                , append = TRUE, row.names = FALSE
	                , col.names = FALSE
	                , sep = ",", qmethod = "double") %>% suppressWarnings
	  }
	  cat("\n", file = csv, append = TRUE)
	}

  # Important for integrating the output into other programming tasks
  # names(df1) %<>% make.unique
  rownames(df1) = NULL
  class(df1) = c("surveytable_table", "data.frame")
	df1
}
