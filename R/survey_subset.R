#' Subset a survey, while preserving variable labels
#'
#' @param design a survey design object
#' @param subset an expression specifying the subpopulation
#' @param label survey label of the newly created survey design object
#'
#' @return a new survey design object
#' @export
#'
#' @examples
#' \dontrun{
#' children = survey_subset(vars2019, AGE < 18, "Children")
#' set_survey("children")
#' tab("AGER")
#' }
survey_subset = function(design, subset, label) {
  assert_that(inherits(design, "survey.design")
              , msg = paste0("Must be a survey.design. Is ", class(design)[1] ))

  vls = lapply(design$variables, FUN = function(x) attr(x, "label"))
  nm = names(vls)
  assert_that(all(nm == names(design$variables)))

  # survey:::subset.survey.design
  e <- substitute(subset)
  r <- eval(e, design$variables, parent.frame())
  r <- r & !is.na(r)
  d1 <- design[r, ]
  d1$call = NULL

  assert_that(all(nm == names(d1$variables)))

  for (vr in nm) {
    attr(d1$variables[,vr], "label") = vls[[vr]]
  }

  attr(d1, "label") = label
  d1
}
