#' Convert factor to logical
#'
#' @param newvr   name of the new logical variable to be created
#' @param vr factor variable
#' @param cases one or more levels of `vr` that are converted to `TRUE`. All other levels are converted to `FALSE`.
#' @param retain_na for the observations where `vr` is `NA`, should `newvr` be `NA` as well?
#'
#' @return Survey object
#' @family variables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#'
#' var_case("Preventive care visits", "MAJOR", "Preventive care")
#' tab("Preventive care visits")
#'
#' var_case("Surgery-related visits"
#' , "MAJOR"
#' , c("Pre-surgery", "Post-surgery"))
#' tab("Surgery-related visits")
#'
#' var_case("Non-primary"
#' , "SPECCAT.bad"
#' , c("Surgical care specialty", "Medical care specialty"))
#' tab("Non-primary")
#' tab("Non-primary", drop_na = TRUE)
var_case = function(newvr, vr, cases, retain_na = TRUE) {
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(is.factor(design$variables[,vr])
          , msg = paste0(vr, ": must be a factor. Is ", class(design$variables[,vr])[1] ))
  assert_that(all(cases %in% levels(design$variables[,vr]) )
            , msg = paste0(vr, ": at least some of the specified levels do not exist."))

  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  design$variables[,newvr] = FALSE
  if (retain_na) {
    idx = which(is.na(design$variables[,vr]))
    design$variables[idx, newvr] = NA
  }
  idx = which(design$variables[,vr] %in% cases)
  design$variables[idx, newvr] = TRUE

  env$survey = design
}
