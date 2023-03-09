.write_out = function(df1, screen, out) {
  if (!is.null(txt <- attr(df1, "title"))) {
    txt %<>% paste0(" [", getOption("prettysurvey.design"), "]")
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

    gow = getOption("width")
    options(width = 10)
    hh %>% print(colnames = FALSE, min_width = 0, max_width = Inf)
    options(width = gow)
    cat("\n")
  }

	if (nzchar(out)) {
	  if (!is.null(txt <- attr(df1, "title"))) {
	    write.table(txt, file = out
	                , append = TRUE, row.names = FALSE
	                , col.names = FALSE
	                , sep = ",", qmethod = "double") %>% suppressWarnings
	  }
	  write.table(df1, file = out
	              , append = TRUE, row.names = FALSE
	              , sep = ",", qmethod = "double") %>% suppressWarnings
	  if (!is.null(txt <- attr(df1, "footer"))) {
	    write.table(txt, file = out
	                , append = TRUE, row.names = FALSE
	                , col.names = FALSE
	                , sep = ",", qmethod = "double") %>% suppressWarnings
	  }
	  cat("\n", file = out, append = TRUE)
	}
	invisible(df1)
}
