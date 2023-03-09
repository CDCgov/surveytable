#' Specify the survey from which you would like to tabulate the estimates from
#'
#' You need to do this before the other functions, such as [tab()], will work.
#'
#' `show_survey()` shows the survey that you've set.
#'
#' @param survey_name the name of a `survey.design` object (in quotation marks)
#'
#' @return (Nothing.)
#' @family options
#' @export
#'
#' @examples
#' set_survey("vars2019")
#' show_survey()
set_survey = function(survey_name = "") {
  assert_that(is.character(survey_name), nzchar(survey_name)
              , msg = "survey_name must be a character string.")
  tmp = get0(survey_name)
  assert_that(!is.null(tmp)
      , msg = paste0(survey_name, " does not exist. Did you forget to load it?"))
  assert_that(inherits(tmp, "survey.design")
      , msg = paste0(survey_name, " must be a survey.design. Is: ", class(tmp) ))

  options(prettysurvey.design = survey_name)
  message("* Analyzing ", survey_name)
}

#' @rdname set_survey
#' @export
show_survey = function() {
  survey_name = getOption("prettysurvey.design")
  message("* Analyzing ", survey_name)

  design = .load_survey()
  print(design)
  invisible(NULL)
}

.load_survey = function() {
  survey_name = getOption("prettysurvey.design")
  assert_that(is.character(survey_name), nzchar(survey_name)
              , msg = "Option prettysurvey.design must be a character string. See ?set_survey")
  tmp = get0(survey_name)
  assert_that(!is.null(tmp)
              , msg = paste0(survey_name, " does not exist. Did you forget to load it? See ?set_survey"))
  assert_that(inherits(tmp, "survey.design")
              , msg = paste0(survey_name, " must be a survey.design. Is: ", class(tmp) ))
  tmp
}
