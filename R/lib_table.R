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
#' @param design  survey design
#' @param ...     names of variables (in quotes)
#' @param raw     also output raw counts? (Useful for performing further calculations
#' , such as calculating rates.)
#' @param max.levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param screen  print to the screen?
#' @param prefix  prefix of a file name to send output to
#'
#' @return a list of `huxtable` tables.
#' @export
#'
#' @examples
#' tab(namcs2019, "MDDO", "SPECCAT", "MSA")
tab = function(design, ...
               , raw = opts$tab$raw
               , max.levels = opts$out$max.levels
               , screen = opts$out$screen
               , prefix = opts$out$prefix
               ) {
	ret = list()
	if (...length() > 0) {
		for (ii in 1:...length()) {
			vr = ...elt(ii)
			ret[[vr]] = .tab_factor(design = design
				, vr = vr
				, raw = raw
				, max.levels = max.levels
				, screen = screen
				, prefix = prefix
				)
			cat("\n\n")
		}
	}
	invisible(ret)
}

.tab_factor = function(design, vr, raw, max.levels, screen, prefix) {
	lbl = attr(design$variables[,vr], "label")
	if (is.logical(design$variables[,vr])) {
		design$variables[,vr] = as.factor(design$variables[,vr])
	}
	assert_that(is.factor(design$variables[,vr])
		, msg = paste0(vr, ": must be either factor or logical. Is ",
			class(design$variables[,vr]) ))
	design$variables[,vr] %<>% droplevels
	attr(design$variables[,vr], "label") = lbl

	nlv = nlevels(design$variables[,vr])
	if (nlv < 2) {
		hh = data.frame(
			Note = paste("All values the same:"
			, design$variables[1,vr])) %>% hux
		caption(hh) = .getvarname(design, vr)
		.write_out(hh, screen = screen, prefix = prefix
		           , name = vr) %>% return()
	} else if (nlv > max.levels) {
		hh = data.frame(
			Note = paste0("Categorical variable with too many levels: "
			, nlv, ", but ", max.levels
			, " allowed. Try increasing the max.levels argument or opts$out$max.levels .")) %>% hux
		caption(hh) = .getvarname(design, vr)
		.write_out(hh, screen = screen, prefix = prefix
		           , name = vr) %>% return()
	}

	frm = as.formula(paste0("~ `", vr, "`"))

	##
	counts = svyby(frm, frm, design, unwtd.count)$counts
	if (!is.null(opts$tab$present$restricted)) {
		pro = opts$tab$present$restricted(counts)
	} else {
		pro = list(flags = rep("", length(counts)), has.flag = c())
	}

	##
	sto = svytotal(frm, design)
	mmcr = data.frame(a = as.numeric(sto)
		, b = sqrt(diag(attr(sto, "var"))) )
	if (!is.null(opts$tab$present$count)) {
		pco = opts$tab$present$count(mmcr, counts)
	} else {
		pco = list(flags = rep("", nrow(mmcr)), has.flag = c())
	}

	# qnorm(.975)
	# Forcing 95% CI because CI for percentages has to be 95%
	kk = 1.95996398454
	mmcr$c = mmcr$a - kk * mmcr$b
	mmcr$d = mmcr$a + kk * mmcr$b
	mmc = opts$tab$counts_tx( mmcr )
	names(mmc) = opts$tab$counts_names

	##
	lvs = design$variables[,vr] %>% levels %>% .fix_levels
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

	if (!is.null(opts$tab$present$prop)) {
		ppo = opts$tab$present$prop(ret)
	} else {
		nlvs = design$variables[, vr] %>% nlevels
		ppo = list(flags = rep("", nlvs), has.flag = c())
	}

	mp2 = opts$tab$prct_tx(ret[,c("Proportion", "SE", "LL", "UL")])
	names(mp2) = opts$tab$prct_names

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
	hh = mp %>% hux
	number_format(hh)[-1,1:4] = fmt_pretty()
	if (raw) {
	  names(mmcr) = c("Count", "SE")
	  hhe = mmcr[,1:2] %>% hux
	  number_format(hhe)[-1,] = fmt_pretty()
	  hh %<>% add_columns(hhe)
	}

	level_names = design$variables[,vr] %>% levels %>% .fix_levels
	hhl = data.frame(Level = level_names) %>% hux
	hh %<>% add_columns(hhl, after = 0)
	caption(hh) = .getvarname(design, vr)

	##
	hh %<>% .add_flags( c(pro$has.flag, pco$has.flag, ppo$has.flag) )
	.write_out(hh, screen = screen, prefix = prefix, name = vr)
}

.add_flags = function(hh, has.flag) {
	if (is.null(has.flag)) {
		hh %<>% add_footnote("(No flags.)")
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
		hh %<>% add_footnote(v1)
	}
	hh
}

.fix_levels = function(lvs) {
  lvs[is.na(lvs)] = "<NA>"
  lvs
}
