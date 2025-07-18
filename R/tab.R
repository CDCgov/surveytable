#' Tabulate variables
#'
#' Tabulate categorical (factor or character), logical, or numeric variables.
#'
#' For categorical and logical variables, for each category, this function presents the following:
#'
#' * the number of observations (`n`);
#' * the estimated count (`Number`), with its standard error (`SE`) and confidence
#' interval (`LL` and `UL`); and
#' * the estimated percentage (`Percent`), with its standard error (`SE`) and confidence
#' interval (`LL` and `UL`).
#'
#' Optionally, this function identifies low-precision estimates and flags
#' them if, according to the guidelines (such as the NCHS presentation standards), they should
#' be suppressed, footnoted, or reviewed by an analyst. To enable this functionality,
#' see `set_opts()` with arguments `lpe = TRUE` or `mode = "NCHS"`.
#'
#' For numeric variables, this function presents the following:
#'
#' * percentage of observations with known values (`% known`);
#' * the mean of known values (`Mean`), with its standard error (`SEM`) and confidence
#' interval (`LL` and `UL`); and
#' * the standard deviation (`SD`).
#'
#' Confidence intervals (CIs) are calculated at the 95% confidence level. CIs for
#' count estimates are the log Student's t CIs, with adaptations
#' for complex surveys. CIs for percentage estimates are
#' the Korn and Graubard CIs, with optional adjustments. See `set_opts()` argument
#' `adj`. CIs for estimates of means are the Wald CIs.
#'
#' @param ...     names of variables (in quotes)
#' @param test    perform hypothesis tests?
#' @param alpha   significance level for tests
#' @param p_adjust adjust p-values for multiple comparisons?
#' @param drop_na drop missing values (`NA`)? Categorical or logical variables only.
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param csv     name of a CSV file
#'
#' @return A list of tables or a single table.
#' @family tables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' tab("AGER")
#' tab("MDDO", "SPECCAT", "MSA")
#'
#' # Numeric variables
#' tab("NUMMED")
#'
#' # Hypothesis testing with categorical variables
#' tab("AGER", test = TRUE)
tab = function(...
               , test = FALSE, alpha = 0.05, p_adjust = FALSE
               , drop_na = getOption("surveytable.drop_na")
               , max_levels = getOption("surveytable.max_levels")
               , csv = getOption("surveytable.csv")
               ) {
	ret = list()
	if (...length() > 0) {
	  assert_that(test %in% c(TRUE, FALSE)
	              , alpha > 0, alpha < 0.5
	              , p_adjust %in% c(TRUE, FALSE))
	  design = .load_survey()
	  nm = names(design$variables)
		for (ii in 1:...length()) {
			vr = ...elt(ii)
			if (!(vr %in% nm)) {
			  warning(glue("{vr}: variable not in the data."))
			  next
			}
			if (is.logical(design$variables[,vr])
			    || is.factor(design$variables[,vr]) ) {
			  ret[[vr]] = .tab_factor(design = design
                      , vr = vr
                      , drop_na = drop_na
                      , max_levels = max_levels
                      , csv = csv)
			  if (test) {
			    ret[[paste0(vr, " - test")]] = .test_factor(design = design
                                            , vr = vr
                                            , drop_na = drop_na
                                            , alpha = alpha
                                            , p_adjust = p_adjust
                                            , csv = csv)
			  }
			} else if (is.numeric(design$variables[,vr])) {
			  ret[[vr]] = .tab_numeric(design = design
                      , vr = vr
                      , csv = csv)
			} else {
        warning(glue("{vr}: must be logical, categorical (factor or character),",
          " or numeric. Is {o2s(design$variables[,vr])}"))
			}
		}
	}

	class(ret) = "surveytable_list"
	if (length(ret) == 1L) ret[[1]] else ret
}

.tab_factor = function(design, vr, drop_na, max_levels, csv) {
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))

	lbl = .getvarname(design, vr)
	if (is.logical(design$variables[,vr])) {
		design$variables[,vr] %<>% factor
	}
	assert_that(is.factor(design$variables[,vr])
		, msg = paste0(vr, ": must be either factor or logical. Is ",
			class(design$variables[,vr])[1] ))
	design$variables[,vr] %<>% droplevels
	if (drop_na) {
	  idx = which(is.na(levels(design$variables[,vr])))
	  if (length(idx) > 0) {
	    idx.ok = which( !(design$variables[,vr] %>% as.numeric %in% idx))
      design = design[idx.ok,]
      design$variables[,vr] %<>% droplevels
	  }
	  design = design[which(!is.na(design$variables[,vr])),]

	  if(inherits(design, "svyrep.design")) {
	    design$prob = 1 / design$pweights
	  }
	  lbl %<>% paste("(knowns only)")
	} else {
	  design$variables[,vr] %<>% .fix_factor
	}
	assert_that(noNA(design$variables[,vr]), noNA(levels(design$variables[,vr])))
	attr(design$variables[,vr], "label") = lbl

	nlv = nlevels(design$variables[,vr])
	if (nlv < 2) {
    assert_that(all(design$variables[,vr] == design$variables[1,vr]))
	  mp = .total(design)
	  fa = attr(mp, "footer")
	  mp = cbind(
	    data.frame(Level = design$variables[1,vr])
      , mp)
	  if (!is.null(fa)) {
	    attr(mp, "footer") = fa
	  }
	  attr(mp, "num") = 2:6
	  attr(mp, "title") = .getvarname(design, vr)
    return(.write_out(mp, csv = csv))
	} else if (nlv > max_levels) {
	  # don't use assert_that
	  # if multiple tables are being produced, want to go to the next table
	  warning(glue("{vr}: categorical variable with too many levels: {nlv}, but {max_levels}"
	               , " allowed. Try increasing the max_levels argument or see ?set_opts"))
	  return(invisible(NULL))
	}

	frm = as.formula(paste0("~ `", vr, "`"))

	##
	counts = svyby(frm, frm, design, unwtd.count)$counts
	assert_that(length(counts) == nlv)
	if (getOption("surveytable.find_lpe")) {
	  assert_that(is.vector(counts), all(counts >= 1), is.numeric(counts)
	              , all(counts == trunc(counts)))
	  pro = getOption("surveytable.lpe_n") %>% do.call(list(counts))
	  assert_that(is.list(pro)
	              , setequal(names(pro), c("id", "descriptions", "flags", "has.flag"))
	              , all(pro$has.flag %in% names(pro$descriptions)))
	}

	##
	sto = svytotal(frm, design) # , deff = "replace")
	mmcr = data.frame(x = sto %>% as.numeric()
	                  , s = sto %>% SE() %>% as.numeric())
	mmcr$counts = counts
	counts_sum = sum(counts)

	# deff = attr(sto, "deff") %>% diag (CAREFUL with diag() usage if scalar)
	# I am having trouble interpreting this deff.
	# In some situations, results are unusual.
	# total(), tab("AGER"), tab("PAYNOCHG")
	# Using Kish design effect instead.

	mmcr$deff = by(design$prob, design$variables[,vr], deffK) %>% as.numeric
	mmcr$samp.size = mmcr$counts / mmcr$deff
	idx.bad = which(mmcr$samp.size > mmcr$counts)
	mmcr$samp.size[idx.bad] = mmcr$counts[idx.bad]

  df1 = degf(design)
  mmcr$degf = df1

  # Equation 24 https://www.cdc.gov/nchs/data/series/sr_02/sr02-200.pdf
  # DF should be as here, not just sample size.
  mmcr$k = qt(0.975, pmax(mmcr$samp.size - 1, 0.1)) * mmcr$s / mmcr$x
  mmcr$lnx = log(mmcr$x)
  mmcr$ll = exp(mmcr$lnx - mmcr$k)
  mmcr$ul = exp(mmcr$lnx + mmcr$k)

	if (getOption("surveytable.find_lpe")) {
	  assert_that(is.data.frame(mmcr), nrow(mmcr) >= 1
	              , all(c("x", "s", "ll", "ul", "samp.size", "counts", "degf") %in% names(mmcr)))
	  pco = getOption("surveytable.lpe_counts") %>% do.call(list(mmcr))
	  assert_that(is.list(pco)
	              , setequal(names(pco), c("id", "descriptions", "flags", "has.flag"))
	              , all(pco$has.flag %in% names(pco$descriptions)))
	}

  mmc = mmcr[,c("x", "s", "ll", "ul")]
  mmc = getOption("surveytable.tx_count") %>% do.call(list(mmc))
	mmc$counts = mmcr$counts
	mmc = mmc[,c("counts", "x", "s", "ll", "ul")]
	names(mmc) = .get_names_count()

	##
	lvs = design$variables[,vr] %>% levels
	assert_that( noNA(lvs) )
	ret = NULL
	for (lv in lvs) {
		design$variables$.tmp = NULL
		design$variables$.tmp = (design$variables[,vr] == lv)
		# Korn and Graubard, 1998
		xp = svyciprop_adjusted(formula = ~ .tmp, design = design, level = 0.95
		                        , adj = getOption("surveytable.svyciprop_adj"))
		ret1 = data.frame(Proportion = xp %>% as.numeric
		                  , SE = attr(xp, "var") %>% as.numeric %>% sqrt)

		ci = attr(xp, "ci") %>% t %>% data.frame
		names(ci) = c("LL", "UL")
		if (is.na(ci$LL)) ci$LL = 0
		if (is.na(ci$UL)) ci$UL = 1

		# If SE = 0, n > 0, then LL = UL = 0.5
		if (ret1$SE == 0) {
		  ci$LL = ci$UL = ret1$Proportion
		}
		assert_that(ret1$SE >= 0, ci$LL <= ret1$Proportion, ci$UL >= ret1$Proportion)
		ret1 %<>% cbind(ci)

		ret1$`n numerator` = sum(design$variables$.tmp)
		ret1$`n denominator` = length(design$variables$.tmp)
		ret = rbind(ret, ret1)
	}
	ret$degf = df1

	if (getOption("surveytable.find_lpe")) {
	  assert_that(is.data.frame(ret), nrow(ret) >= 1
    , all(c("Proportion", "SE", "LL", "UL", "n numerator", "n denominator") %in% names(ret)))
	  ppo = getOption("surveytable.lpe_percents") %>% do.call(list(ret))
	  assert_that(is.list(ppo)
	              , setequal(names(ppo), c("id", "descriptions", "flags", "has.flag"))
	              , all(ppo$has.flag %in% names(ppo$descriptions)))
	}

	mp2 = ret[,c("Proportion", "SE", "LL", "UL")]
	mp2 = getOption("surveytable.tx_prct") %>% do.call(list(mp2))
	names(mp2) = getOption("surveytable.names_prct")

	##
	assert_that(nrow(mmc) == nrow(mp2)
    , nrow(mmc) == nrow(mmcr))
	mp = cbind(mmc, mp2)

	##
	rownames(mp) = NULL
	mp = cbind(data.frame(Level = lvs), mp)

	attr(mp, "num") = 2:6
	attr(mp, "title") = .getvarname(design, vr)
	attr(mp, "footer") = paste0("N = ", counts_sum, ".")

	if (getOption("surveytable.find_lpe")) {
	  assert_that(nrow(mmc) == length(pro$flags)
            , nrow(mmc) == length(pco$flags)
            , nrow(mmc) == length(ppo$flags))
	  flags = paste(pro$flags, pco$flags, ppo$flags) %>% trimws
	  if (any(nzchar(flags))) {
	    mp$Flags = flags
	  }
	  mp %<>% .add_flags( list(pro, pco, ppo) )
	}

	.write_out(mp, csv = csv)
}

.add_flags = function(df1, lfo) {
  if (!getOption("surveytable.find_lpe")) {
    return(df1)
  }

  retR = list()
  retNR = c()
  for (fo in lfo) {
    if (!is.null(fo$has.flag)) {
      v1 = paste0(fo$descriptions[ fo$has.flag ], collapse = "; ")
      if (is.null(retR[[ fo$id ]])) {
        retR[[ fo$id ]] = v1
      } else {
        retR[[ fo$id ]] %<>% paste(v1, sep = "; ")
      }
    }
    retNR %<>% c(fo$id)
  }
  retNR %<>% unique
  retNR = retNR[which( !(retNR %in% names(retR)))]
  assert_that(!(is.null(retR) && length(retNR) == 0))

  ret = ""
  if (!is.null(retR)) {
    for (nn in names(retR)) {
      v1 = paste0("Checked ", nn, ": ", retR[[nn]], ".")
      ret %<>% paste(v1)
    }
  }
  if (length(retNR) > 0) {
    v1 = paste0("Checked ", paste(retNR, collapse = ", "), ". Nothing to report.")
    ret %<>% paste(v1)
  }

  if (is.null(v1 <- attr(df1, "footer"))) {
    attr(df1, "footer") = ret
  } else {
    attr(df1, "footer") = paste0(v1, ret)
  }
  df1
}
