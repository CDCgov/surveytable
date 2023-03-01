#' Number of variables in a survey design.
#'
#' @param design  survey design
#' @param screen  print to the screen?
#' @param prefix  prefix of a file name to send output to
#'
#' @return `huxtable`
#' @export
#'
#' @examples
#' var_num(namcs2019)
var_num = function(design
            , screen = opts$out$screen
            , prefix = opts$out$prefix
            ) {
	hh = data.frame(Value = c(ncol(design$variables)
		, nrow(design$variables)) ) %>% hux
	hhl = data.frame(What = c("Number of variables"
		, "Number of observations") ) %>% hux
	hh %<>% add_columns(hhl, after = 0)
	number_format(hh)[-1,2] = fmt_pretty()
	hh = hh[-1,]
	caption(hh) = "Data summary"
	.write_out(hh, screen = screen, prefix = prefix, name = "Summary")
}

#' List variables in a survey design
#'
#' @param design  survey design
#' @param sw      starting characters in variable name (case insensitive)
#' @param all     print all variables?
#' @param screen  print to the screen?
#' @param prefix  prefix of a file name to send output to
#'
#' @return `huxtable`
#' @export
#'
#' @examples
#' var_list(namcs2019, "age")
var_list = function(design, sw = "", all=FALSE
                    , screen = opts$out$screen
                    , prefix = opts$out$prefix
                    ) {
	assert_that(nzchar(sw) | all
    , msg = "Either set the 'sw' argument to a non-empty string, or set all=TRUE")
	nn = names(design$variables)
	if (!all) {
		sw %<>% tolower
		idx = nn %>% tolower %>% startsWith(sw)
		nn = nn[idx]
	}

	ret = NULL
	for (ii in nn) {
		r1 = data.frame(
			Variable = ii
			, Class = paste(class(design$variables[,ii])
				, collapse = ", ")
			, Label = .getvarname(design, ii)
		)
		ret = rbind(ret, r1)
	}

	hh = ret %>% hux
	caption(hh) = if (all) {
			"ALL variables"
		} else {
			paste0("Variables beginning with '", sw, "'")
		}
	.write_out(hh, screen = screen, prefix = prefix, name = "Variables")
}

.getvarname = function(design, vr) {
  nm = attr(design$variables[,vr], "label")
  if (is.null(nm)) nm = vr
  nm
}

