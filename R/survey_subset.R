#' Subset a survey, while preserving variable labels
#'
#' @param design a survey object
#' @param subset an expression specifying the sub-population
#' @param label survey label of the newly created survey object
#'
#' @return a new survey object
#' @export
#'
#' @examples
#' children = survey_subset(namcs2019sv, AGE < 18, "Children < 18")
#' set_survey(children)
#' tab("AGER")
survey_subset = function(design, subset, label) {
  # See set_survey()
  assert_that(inherits(design, c("survey.design", "svyrep.design"))
              , msg = glue("Must be a survey object (survey.design or svyrep.design). Is: {o2s(design)}."))
  # get rid of non-`data.frame` classes (like tbl_df), which cause problems
  design$variables %<>% as.data.frame()

  ##
  vls = lapply(design$variables, FUN = function(x) attr(x, "label"))
  nm = names(vls)
  assert_that(all(nm == names(design$variables)))

  # survey:::subset.survey.design
  e <- substitute(subset)
  r <- eval(e, design$variables, parent.frame())
  r <- r & !is.na(r)
  d1 <- design[r, ]
  d1$call <- sys.call(0)

  assert_that(all(nm == names(d1$variables)))

  for (vr in nm) {
    attr(d1$variables[,vr], "label") = vls[[vr]]
  }

  attr(d1, "label") = label
  d1
}
