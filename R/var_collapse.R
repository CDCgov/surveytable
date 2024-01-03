#' Collapse factor levels
#'
#' Collapse two or more levels of a factor variable into a single level.
#'
#' @param vr factor variable
#' @param newlevel name of the new level
#' @param oldlevels vector of old levels
#'
#' @return (Nothing.)
#' @family variables
#' @export
#'
#' @examples
#' set_survey("namcs2019sv")
#' tab("PRIMCARE")
#' var_collapse("PRIMCARE", "Unknown if PCP", c("Blank", "Unknown"))
#' tab("PRIMCARE")
var_collapse = function(vr, newlevel, oldlevels) {
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(is.factor(design$variables[,vr])
            , msg = paste0(vr, ": must be a factor. Is ", class(design$variables[,vr])[1] ))
  assert_that(any(oldlevels %in% levels(design$variables[,vr]) )
            , msg = paste0(vr, ": none of the specified levels exist."))

  idx = which(levels(design$variables[,vr]) %in% oldlevels)
  levels(design$variables[,vr])[idx] = newlevel

  assign(getOption("surveytable.survey"), design, envir = getOption("surveytable.survey_envir"))
}
