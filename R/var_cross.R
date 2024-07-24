#' Cross or interact two variables
#'
#' Create a new variable which is an interaction of two other variables. Also
#' see [`tab_cross()`].
#'
#' @param newvr   name of the new variable to be created
#' @param vr      first variable
#' @param vrby    second variable
#'
#' @return Survey object
#' @family variables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' var_cross("Age x Sex", "AGER", "SEX")
#' tab("Age x Sex")
var_cross = function(newvr, vr, vrby) {
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(vrby %in% nm, msg = paste("Variable", vrby, "not in the data."))
  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  x1 = design$variables[,vr]
  x2 = design$variables[,vrby]
  if (is.logical(x1)) {
    x1 %<>% factor
  }
  if (is.logical(x2)) {
    x2 %<>% factor
  }
  assert_that(is.factor(x1)
              , msg = paste0(vr, ": must be either factor or logical. Is ",
                             class(design$variables[,vr])[1] ))
  assert_that(is.factor(x2)
              , msg = paste0(vrby, ": must be either factor or logical. Is ",
                             class(design$variables[,vrby])[1] ))
  x1 %<>% .fix_factor
  x2 %<>% .fix_factor
  design$variables[,newvr] = interaction(x1, x2
                              , drop = TRUE
                              , sep = ": ")
  # attr(design$variables[,newvr], "label") = paste0(
  #   "(", .getvarname(design, vr), ") x ("
  #   , .getvarname(design, vrby), ")")

  env$survey = design
}
