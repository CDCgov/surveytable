#' Specify the survey to analyze
#'
#' You need to specify a survey before the other functions, such as [tab()],
#' will work.
#'
#' Optionally, the survey can have an attribute called `label`, which is the
#' long name of the survey.
#'
#' Optionally, each variable in the survey can have an attribute called `label`,
#' which is the variable's long name.
#'
#' @param design a survey object (`survey.design` or `svyrep.design`)
#'
#' @return Object with info about the survey.
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
set_survey = function(design) {
  # In case there's an error below and we don't set a new survey,
  # don't retain the previous survey either.
  env$survey = NULL
  options(surveytable.survey_label = "")

  if (is.string(design)) {
    label_default = design
    design %<>% get0
  } else {
    label_default = as.character(substitute(design))
  }

  assert_that(inherits(design, c("survey.design", "svyrep.design"))
      , msg = paste0(label_default, " must be a survey.design or svyrep.design. Is "
      , class(design)[1] ))

  if(is.null( attr(design, "label") )) {
    attr(design, "label") = label_default
  }
  assert_that(is.string(attr(design, "label")), nzchar(attr(design, "label"))
              , msg = "Survey must have a label.")

  if(inherits(design, "svyrep.design") && !isTRUE(attr(design, "prob_set"))) {
    assert_that(!("prob" %in% names(design))
      , msg = "prob already exists")
    design$prob = 1 / design$pweights
    attr(design, "prob_set") = TRUE
  }

  # zero weights cause issues with tab():
  # counts = svyby(frm, frm, design, unwtd.count)$counts
  # assert_that(length(neff) == length(counts))
  #
  # prob == 1 / weight ?
  if (any(design$prob == Inf)) {
    message(paste0("* ", label_default, ": retaining positive weights only."))
    dl = attr(design, "label")
    dl %<>% paste("(positive weights only)")
    design %<>% survey_subset(design$prob < Inf, label = dl)
  }
  assert_that( all(design$prob > 0), all(design$prob < Inf) )

  options(surveytable.survey_label = attr(design, "label"))
  env$survey = design
  message("* To adjust how counts are rounded, see ?set_count_int")

  out = list()
  out = list(`Survey name` = getOption("surveytable.survey_label")
             , `Number of variables` = ncol(design$variables)
             , `Number of observations` = nrow(design$variables)
             , `Info` = design %>% capture.output
             )
  class(out) = "simple.list"
  out
}


.load_survey = function() {
  design = env$survey
  assert_that(!is.null(design)
      , msg = "Survey has not been specified. See ?set_survey")
  assert_that(inherits(design, c("survey.design", "svyrep.design"))
              , msg = paste0("Must be a survey.design or svyrep.design. Is "
                             , class(design)[1] ))
  assert_that( all(design$prob > 0), all(design$prob < Inf) )
  design
}
