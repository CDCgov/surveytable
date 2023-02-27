#' Total count
#'
#' @param design  survey design
#' @param out     (optional) file name for output 
#'
#' @return `huxtable`
#' @export
#'
#' @examples
#' total(namcs2019)
total = function(design, out = opts$out$fname) {
	design$variables$Total = 1
	
	##
	counts = nrow(design$variables)
	if (!is.null(opts$tab$present_restricted)) {
		pro = opts$tab$present_restricted(counts)
	} else {
		pro = list(flags = rep("", length(counts)), has.flag = c())
	}

	##
	sto = svytotal(~Total, design)
	mmcr = data.frame(a = as.numeric(sto)
		, b = sqrt(diag(attr(sto, "var"))) )
	if (!is.null(opts$tab$present_count)) {
		pco = opts$tab$present_count(mmcr, counts)
	} else {
		pco = list(flags = rep("", nrow(mmcr)), has.flag = c())
	}

	# qnorm(.975)
	# See .tab_factor
	kk = 1.95996398454
	mmcr$c = mmcr$a - kk * mmcr$b
	mmcr$d = mmcr$a + kk * mmcr$b
	mmc = opts$tab$counts_tx( mmcr )
	names(mmc) = opts$tab$counts_names

	##
	assert_that(nrow(mmc) == 1
		, nrow(mmc) == length(pro$flags)
		, nrow(mmc) == length(pco$flags))
	
	mp = mmc
	flags = paste(pro$flags, pco$flags) %>% trimws
	if (any(nzchar(flags))) {
		mp$Flags = flags
	}

	##
	hh = mp %>% hux
	number_format(hh)[-1,1:4] = fmt_pretty()
	caption(hh) = "Total"
	
	##
	hh %<>% .add_flags( c(pro$has.flag, pco$has.flag) )	
	.write_out(hh, fname = out)
}