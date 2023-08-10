.write_out = function(df1, screen, csv) {
  if (!is.null(txt <- attr(df1, "title"))) {
    txt %<>% paste0(" {", getOption("surveytable.survey_label"), "}")
    attr(df1, "title") = txt
  }

  if (screen) {
    hh = df1 %>% hux %>% set_all_borders
	  if (!is.null(txt <- attr(df1, "title"))) {
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
      options(width = 10)
      hh %>% print_screen(colnames = FALSE, min_width = 0, max_width = max(gow * 1.5, 150, na.rm=TRUE))
      options(width = gow)
      cat("\n")
    }
  }

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
  names(df1) %<>% make.unique
	invisible(df1)
}
