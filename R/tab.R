#' Tabulate variables
#'
#' Operates on categorical and logical variables, and presents the estimated
#' counts, their standard errors (SEs) and confidence intervals (CIs),
#' percentages, and their SEs and CIs. Checks the presentation guidelines for
#' counts and percentages and flags estimates if, according to the guidelines,
#' they should be suppressed, footnoted, or reviewed by an analyst. CIs are
#' calculated at the 95% confidence level. CIs for the percentage estimates are
#' calculated using the Korn and Graubard method.
#'
#' @param ...     names of variables (in quotes)
#' @param max.levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param screen  print to the screen?
#' @param out     file name of CSV file
#'
#' @return a list of `data.frame` tables.
#' @family tables
#' @export
#'
#' @examples
#' set_survey("vars2019")
#' tab("AGER")
#' tab("MDDO", "SPECCAT", "MSA")
tab = function(...
               , max.levels = getOption("prettysurvey.out.max_levels")
               , screen = getOption("prettysurvey.out.screen")
               , out = getOption("prettysurvey.out.fname")
               ) {
  design = .load_survey()
	ret = list()
	if (...length() > 0) {
		for (ii in 1:...length()) {
			vr = ...elt(ii)
			ret[[vr]] = .tab_factor(design = design
				, vr = vr
				, max.levels = max.levels
				, screen = screen
				, out = out
				)
		}
	}
	invisible(ret)
}

.tab_factor = function(design, vr, max.levels, screen, out) {
	lbl = attr(design$variables[,vr], "label")
	if (is.logical(design$variables[,vr])) {
		design$variables[,vr] %<>% factor
	}
	assert_that(is.factor(design$variables[,vr])
		, msg = paste0(vr, ": must be either factor or logical. Is ",
			class(design$variables[,vr]) ))
	design$variables[,vr] %<>% droplevels %>% .fix_factor
	attr(design$variables[,vr], "label") = lbl

	nlv = nlevels(design$variables[,vr])
	if (nlv < 2) {
		df1 = data.frame(
			Note = paste("All values the same:"
			, design$variables[1,vr]))
		attr(df1, "title") = .getvarname(design, vr)
		return( .write_out(df1, screen = screen, out = out) )
	} else if (nlv > max.levels) {
		df1 = data.frame(
			Note = paste0("Categorical variable with too many levels: "
			, nlv, ", but ", max.levels
			, " allowed. Try increasing the max.levels argument or the "
			, "prettysurvey.out.max_levels option ."))
		attr(df1, "title") = .getvarname(design, vr)
		return( .write_out(df1, screen = screen, out = out) )
	}

	frm = as.formula(paste0("~ `", vr, "`"))

	##
	counts = svyby(frm, frm, design, unwtd.count)$counts
	if (getOption("prettysurvey.tab.do_present")) {
	  pro = getOption("prettysurvey.tab.present_restricted") %>% do.call(list(counts))
	} else {
		pro = list(flags = rep("", length(counts)), has.flag = c())
	}

	##
	sto = svytotal(frm, design)
	mmcr = data.frame(a = as.numeric(sto)
		, b = sqrt(diag(attr(sto, "var"))) )
	if (getOption("prettysurvey.tab.do_present")) {
	  pco = getOption("prettysurvey.tab.present_count") %>% do.call(list(mmcr, counts))
	} else {
		pco = list(flags = rep("", nrow(mmcr)), has.flag = c())
	}

	# qnorm(.975)
	# Forcing 95% CI because CI for percentages has to be 95%
	kk = 1.95996398454
	mmcr$c = pmax(mmcr$a - kk * mmcr$b, 0)
	mmcr$d = mmcr$a + kk * mmcr$b
	mmc = getOption("prettysurvey.tab.tx_count") %>% do.call(list(mmcr))
	names(mmc) = getOption("prettysurvey.tab.names_count")

	##
	lvs = design$variables[,vr] %>% levels
	levels(design$variables[,vr]) = lvs
	assert_that( all(!is.na(lvs)) )
	ret = NULL
	df1 = degf(design)
	# ret needs to have these names
	for (lv in lvs) {
		design$variables$.tmp = NULL
		design$variables$.tmp = (design$variables[,vr] == lv)
		xp = svyciprop(~ .tmp, design, method="beta")	# Korn and Graubard, 1998
		ret1 = data.frame(Proportion = unclass(xp)[1], SE = SE(xp))

		# 95% CI
		# not giving the user the ability to change this
		# because the presentation standard uses 95% CI
		ci = confint(xp, df = df1)
		dimnames(ci)[[2]] = c("LL", "UL")
		ret1 %<>% cbind(ci)

		ret1$`n numerator` = sum(design$variables$.tmp)
		ret1$`n denominator` = length(design$variables$.tmp)
		ret = rbind(ret, ret1)
	}
	ret$degf = df1

	if (getOption("prettysurvey.tab.do_present")) {
	  ppo = getOption("prettysurvey.tab.present_prop") %>% do.call(list(ret))
	} else {
		nlvs = design$variables[, vr] %>% nlevels
		ppo = list(flags = rep("", nlvs), has.flag = c())
	}

	mp2 = getOption("prettysurvey.tab.tx_prct") %>% do.call(list(ret[,c("Proportion", "SE", "LL", "UL")]))
	names(mp2) = getOption("prettysurvey.tab.names_prct")

	##
	assert_that(nrow(mmc) == nrow(mp2)
    , nrow(mmc) == nrow(mmcr)
		, nrow(mmc) == length(pro$flags)
		, nrow(mmc) == length(pco$flags)
		, nrow(mmc) == length(ppo$flags) )

	mp = cbind(mmc, mp2)
	flags = paste(pro$flags, pco$flags, ppo$flags) %>% trimws
	if (any(nzchar(flags))) {
		mp$Flags = flags
	}

	##
	rownames(mp) = NULL
	level_names = design$variables[,vr] %>% levels
	mp = cbind(data.frame(Level = level_names), mp)

  attr(mp, "num") = 2:5
  attr(mp, "title") = .getvarname(design, vr)
	mp %<>% .add_flags( c(pro$has.flag, pco$has.flag, ppo$has.flag) )
	.write_out(mp, screen = screen, out = out)
}

.add_flags = function(df1, has.flag) {
	if (is.null(has.flag)) {
	  attr(df1, "footer") = "(No flags.)"
	} else {
		v1 = c()
		for (ff in has.flag) {
			v1 %<>% c(switch(ff
				, R = "R: If the data is confidential, suppress *all* estimates, SE's, CI's, etc."
				, Cx = "Cx: suppress count"
				, Cr = "Cr: footnote count - RSE"
				, Px = "Px: suppress percent"
				, Pc = "Pc: footnote percent - complement"
				, Pdf = "Pdf: review percent - degrees of freedom"
				, P0 = "P0: review percent - 0% or 100%"
				, paste0(ff, ": unknown flag!")
			))
		}
		v1 %<>% paste(collapse="; ")
		attr(df1, "footer") = v1 %>% paste(collapse="; ")
	}
  df1
}
