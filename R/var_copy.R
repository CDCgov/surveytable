#' Copy a variable
#'
#' Create a new variable that is a copy of another variable. You can modify the copy,
#' while the original remains unchanged. See examples.
#'
#' @param newvr   name of the new variable to be created
#' @param vr variable
#'
#' @return (Nothing.)
#' @family variables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' var_copy("Age group", "AGER")
#' var_collapse("Age group", "65+", c("65-74 years", "75 years and over"))
#' var_collapse("Age group", "25-64", c("25-44 years", "45-64 years"))
#' tab("AGER", "Age group")
var_copy = function(newvr, vr) {
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  design$variables[,newvr] = design$variables[,vr]
  # attr(design$variables[,newvr], "label") = .getvarname(design, vr)
  attr(design$variables[,newvr], "label") = NULL
  env$survey = design
}
