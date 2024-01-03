#' Specify the survey to analyze
#'
#' You need to specify a survey before the other functions, such as [tab()],
#' will work.
#'
#' `show_survey()` shows the survey that you've specified.
#'
#' Optionally, the survey can have an attribute called `label`, which is the
#' long name of the survey.
#'
#' Optionally, each variable in the survey can have an attribute called `label`,
#' which is the variable's long name.
#'
#' @param survey_name the name of a survey object (`survey.design` or `svyrep.design`), in quotation marks
#'
#' @return (Nothing.)
#' @family options
#' @export
#'
#' @examples
#' set_survey("namcs2019sv")
#' show_survey()
set_survey = function(survey_name = "") {
  # In case there's an error below and we don't set a new survey,
  # don't retain the previous survey either.
  options(surveytable.survey = "")

  assert_that(is.string(survey_name), nzchar(survey_name)
              , msg = "survey_name must be a character string.")
  design = get0(survey_name)
  assert_that(!is.null(design)
      , msg = paste0(survey_name, " does not exist. Did you forget to load it?"))
  assert_that(inherits(design, c("survey.design", "svyrep.design"))
      , msg = paste0(survey_name, " must be a survey.design or svyrep.design. Is "
      , class(design)[1] ))

  options(surveytable.survey = survey_name)

  if(inherits(design, "svyrep.design") && !isTRUE(attr(design, "prob_set"))) {
    assert_that(!("prob" %in% names(design))
      , msg = "prob already exists")
    design$prob = 1 / design$pweights
    attr(design, "prob_set") = TRUE
    assign(getOption("surveytable.survey"), design, envir = getOption("surveytable.survey_envir"))
  }

  # zero weights cause issues with tab():
  # counts = svyby(frm, frm, design, unwtd.count)$counts
  # assert_that(length(neff) == length(counts))
  #
  # prob == 1 / weight ?
  if (any(design$prob == Inf)) {
    dl = attr(design, "label")
    if(is.null(dl)) dl = survey_name
    assert_that(is.string(dl), nzchar(dl))
    dl %<>% paste("(positive weights only)")

    design %<>% survey_subset(design$prob < Inf, label = dl)

    message(paste0("* ", survey_name, ": retaining positive weights only."))
    assign(getOption("surveytable.survey"), design, envir = getOption("surveytable.survey_envir"))
  }
  assert_that( all(design$prob > 0), all(design$prob < Inf) )

  dl = attr(design, "label")
  if(is.null(dl)) dl = survey_name
  assert_that(is.string(dl), nzchar(dl))
  options(surveytable.survey_label = dl)

  out = list(`Survey name` = dl
             , `Number of variables` = ncol(design$variables)
             , `Number of observations` = nrow(design$variables))
  class(out) = "simple.list"
  print(out)
  print(design)

  message("* To adjust how counts are rounded, see ?set_count_int")
  invisible(NULL)
}

#' @rdname set_survey
#' @export
show_survey = function() {
  dl = getOption("surveytable.survey_label")

  design = .load_survey()
  out = list(`Survey name` = dl
             , `Number of variables` = ncol(design$variables)
             , `Number of observations` = nrow(design$variables))
  class(out) = "simple.list"
  print(out)
  print(design)

  message("* To adjust how counts are rounded, see ?set_count_int")
  invisible(NULL)
}


.load_survey = function() {
  survey_name = getOption("surveytable.survey")
  assert_that(is.string(survey_name), nzchar(survey_name)
    , msg = "You need to specify a survey before the other functions will work. See ?set_survey")
  design = get0(survey_name)
  assert_that(!is.null(design)
      , msg = paste0(survey_name, " does not exist. Did you forget to load it? See ?set_survey"))
  assert_that(inherits(design, c("survey.design", "svyrep.design"))
      , msg = paste0(survey_name, " must be a survey.design or svyrep.design. Is "
      , class(design)[1] ))

  assert_that( all(design$prob > 0), all(design$prob < Inf) )
  design
}
