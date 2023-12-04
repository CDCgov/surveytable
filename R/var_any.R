#' Is any variable true?
#'
#' Create a new variable which is true if any of the variables in a list of
#' variables are true.
#'
#' @param newvr   name of the new variable to be created
#' @param vrs   vector of logical variables
#'
#' @return (Nothing.)
#' @family variables
#' @export
#'
#' @examples
#' set_survey("vars2019")
#' var_any("Imaging services"
#' , c("ANYIMAGE", "BONEDENS", "CATSCAN", "ECHOCARD", "OTHULTRA"
#' , "MAMMO", "MRI", "XRAY", "OTHIMAGE"))
#' tab("Imaging services")
var_any = function(newvr, vrs) {
  design = .load_survey()
  nm = names(design$variables)
  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  design$variables[,newvr] = FALSE
  for (vr in vrs) {
    assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
    assert_that(is.logical(design$variables[,vr])
      , msg = paste0(vr, ": must be logical. Is ", class(design$variables[,vr])[1] ))
    design$variables[,newvr] = design$variables[,newvr] | design$variables[,vr]
  }
  assign(getOption("surveytable.survey"), design, envir = .GlobalEnv)
}
