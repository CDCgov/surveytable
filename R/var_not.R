#' Logical NOT
#'
#' @param newvr   name of the new variable to be created
#' @param vr   a logical variable
#'
#' @return Survey object
#' @family variables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' var_not("Private insurance not used", "PAYPRIV")
var_not = function(newvr, vr) {
  design = .load_survey()
  nm = names(design$variables)
  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(is.logical(design$variables[,vr])
              , msg = paste0(vr, ": must be logical. Is ", class(design$variables[,vr])[1] ))

  design$variables[,newvr] = !design$variables[,vr]
  env$survey = design
}
