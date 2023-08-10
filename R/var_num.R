#' Number of variables in a survey.
#'
#' @param screen  print to the screen?
#' @param csv     name of a CSV file
#'
#' @return `data.frame`
#' @export
#'
#' @examples
#' set_survey("vars2019")
#' var_num()
var_num = function(screen = getOption("surveytable.screen")
            , csv = getOption("surveytable.csv")
            ) {
  design = .load_survey()
  df1 = data.frame(
    What = c("Number of variables"
            , "Number of observations")
    , Value = c(ncol(design$variables)
            , nrow(design$variables)) )
  attr(df1, "num") = 2
  attr(df1, "title") = "Data summary"
	.write_out(df1, screen = screen, csv = csv)
}
