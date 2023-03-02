#' Cross two variables in a survey design
#'
#' @param design  survey design
#' @param newvar  name of the new variable to be created
#' @param var1    first variable
#' @param var2    second variable
#'
#' @return Updated `survey.design`
#' @export
#'
#' @examples
#' namcs2019 = var_cross(namcs2019, "Age x Sex", "AGER", "SEX")
#' tab(namcs2019, "Age x Sex")
var_cross = function(design, newvar, var1, var2) {
	nm = names(design$variables)
	assert_that(!(newvar %in% nm), msg = paste("Variable", newvar, "already exists."))
	assert_that(var1 %in% nm, msg = paste("Variable", var1, "not in the data."))
	assert_that(var2 %in% nm, msg = paste("Variable", var2, "not in the data."))

	design$variables[,newvar] = fct_cross(
		design$variables[,var1]
		, design$variables[,var2])
	attr(design$variables[,newvar], "label") = paste0(
		"(", .getvarname(design, var1), ") x ("
		, .getvarname(design, var2), ")")

	design
}
