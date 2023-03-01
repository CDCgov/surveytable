.write_out = function(hh
                      , screen = TRUE
                      , prefix = ""
                      , name = "") {
	hh = opts$out$hux_format(hh)

	if (screen) {
	  gow = getOption("width")
	  options(width = 10)
	  hh %>% print(colnames = FALSE, min_width = 0, max_width = Inf)
	  options(width = gow)
	}

	if (nzchar(prefix)) {
	  fname = paste0(prefix, "-", name, ".xlsx")
    hh %>% as_Workbook %>% saveWorkbook(fname)
	}
	invisible(hh)
}

.hux_format = function(hh) {
	hh %<>% set_all_borders
}
