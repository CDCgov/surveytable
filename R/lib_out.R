.write_out = function(hh, txt = "", fname = "") {
	hh = opts$out$hux_format(hh)
  hh %>% print(colnames = FALSE)

	if (nzchar(fname)) {
		t1 = if(nzchar(txt)) {
			paste0(Sys.time(), " - ", txt)
		} else {
			Sys.time()
		}
		cat( paste0("<p>", t1, "</p>")
			, to_html(hh)
			, sep="\n\n"
			, file = fname
			, append = TRUE
			)
	}
	invisible(hh)
}

.hux_format = function(hh) {
	hh %<>% set_all_borders
}
