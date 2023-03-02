#' Number of variables in a survey design.
#'
#' @param design  survey design
#' @param screen  print to the screen?
#' @param out     file name of CSV file
#'
#' @return `data.frame`
#' @export
#'
#' @examples
#' var_num(namcs2019)
var_num = function(design
            , screen = getOption("prettysurvey.out.screen")
            , out = getOption("prettysurvey.out.fname")
            ) {
  df1 = data.frame(
    What = c("Number of variables"
            , "Number of observations")
    , Value = c(ncol(design$variables)
            , nrow(design$variables)) )
  attr(df1, "num") = 2
  attr(df1, "title") = "Data summary"
	.write_out(df1, screen = screen, out = out)
}

#' List variables in a survey design
#'
#' @param design  survey design
#' @param sw      starting characters in variable name (case insensitive)
#' @param all     print all variables?
#' @param screen  print to the screen?
#' @param out     file name of CSV file
#'
#' @return `data.frame`
#' @export
#'
#' @examples
#' var_list(namcs2019, "age")
var_list = function(design, sw = "", all=FALSE
                    , screen = getOption("prettysurvey.out.screen")
                    , out = getOption("prettysurvey.out.fname")
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

	attr(ret, "title") = if (all) {
			"ALL variables"
		} else {
			paste0("Variables beginning with '", sw, "'")
		}
	.write_out(ret, screen = screen, out = out)
}

.getvarname = function(design, vr) {
  nm = attr(design$variables[,vr], "label")
  if (is.null(nm)) nm = vr
  nm
}

