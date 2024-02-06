#' Are all the variables true?
#'
#' Create a new variable which is true if all of the variables in a list of
#' variables are true.
#'
#' @param newvr   name of the new variable to be created
#' @param vrs   vector of logical variables
#'
#' @return Survey object
#' @family variables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' var_all("Medicare and Medicaid", c("PAYMCARE", "PAYMCAID"))
#' tab("Medicare and Medicaid")
var_all = function(newvr, vrs) {
  design = .load_survey()
  nm = names(design$variables)
  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  design$variables[,newvr] = TRUE
  for (vr in vrs) {
    assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
    assert_that(is.logical(design$variables[,vr])
                , msg = paste0(vr, ": must be logical. Is ", class(design$variables[,vr])[1] ))
    design$variables[,newvr] = design$variables[,newvr] & design$variables[,vr]
  }
  env$survey = design
}
