#' Number of variables in a survey.
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
