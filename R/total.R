#' Total count
#'
#' @param screen  print to the screen?
#' @param out     file name of CSV file
#'
#' @return `data.frame`
#' @family tables
#' @export
#'
#' @examples
#' set_survey("vars2019")
#' total()
total = function(screen = getOption("prettysurvey.out.screen")
               , out = getOption("prettysurvey.out.fname")
               ) {
  design = .load_survey()
	design$variables$Total = 1

	##
	counts = nrow(design$variables)
	if (getOption("prettysurvey.tab.do_present")) {
	  pro = getOption("prettysurvey.tab.present_restricted") %>% do.call(list(counts))
	} else {
		pro = list(flags = rep("", length(counts)), has.flag = c())
	}

	##
	sto = svytotal(~Total, design)
	mmcr = data.frame(a = as.numeric(sto)
		, b = sqrt(diag(attr(sto, "var"))) )
	if (getOption("prettysurvey.tab.do_present")) {
	  pco = getOption("prettysurvey.tab.present_count") %>% do.call(list(mmcr, counts))
	} else {
		pco = list(flags = rep("", nrow(mmcr)), has.flag = c())
	}

	# qnorm(.975)
	# See .tab_factor
	kk = 1.95996398454
	mmcr$c = mmcr$a - kk * mmcr$b
	mmcr$d = mmcr$a + kk * mmcr$b
	mmc = getOption("prettysurvey.tab.tx_count") %>% do.call(list(mmcr))
	names(mmc) = getOption("prettysurvey.tab.names_count")

	##
	assert_that(nrow(mmc) == 1
	  , nrow(mmcr) == 1
		, nrow(mmc) == length(pro$flags)
		, nrow(mmc) == length(pco$flags))

	mp = mmc
	flags = paste(pro$flags, pco$flags) %>% trimws
	if (any(nzchar(flags))) {
		mp$Flags = flags
	}

	##
	rownames(mp) = NULL
	attr(mp, "num") = 1:4
	attr(mp, "title") = "Total"
	mp %<>% .add_flags( c(pro$has.flag, pco$has.flag) )
	.write_out(mp, screen = screen, out = out)
}
