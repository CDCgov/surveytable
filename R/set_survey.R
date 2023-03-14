#' Specify the survey to analyze
#'
#' You need specify a survey before the other functions, such as [tab()], will work.
#'
#' `show_survey()` shows the survey that you've specified.
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
  assert_that(is.string(survey_name), nzchar(survey_name)
              , msg = "survey_name must be a character string.")
  tmp = get0(survey_name)
  assert_that(!is.null(tmp)
      , msg = paste0(survey_name, " does not exist. Did you forget to load it?"))
  assert_that(inherits(tmp, "survey.design")
      , msg = paste0(survey_name, " must be a survey.design. Is: ", class(tmp) ))

  options(prettysurvey.design = survey_name)

  dl = attr(tmp, "label")
  if(is.null(dl)) dl = survey_name
  assert_that(is.string(dl), nzchar(dl))
  options(prettysurvey.design.label = dl)

  message("* Analyzing ", dl)
  print(tmp)

  message("* To adjust how counts are rounded, see ?set_count_int")
  invisible(NULL)
}

#' @rdname set_survey
#' @export
show_survey = function() {
  dl = getOption("prettysurvey.design.label")
  message("* Analyzing ", dl)

  design = .load_survey()
  print(design)

  message("* To adjust how counts are rounded, see ?set_count_int")
  invisible(NULL)
}

.load_survey = function() {
  survey_name = getOption("prettysurvey.design")
  assert_that(is.string(survey_name), nzchar(survey_name)
              , msg = "Option prettysurvey.design must be a character string. See ?set_survey")
  tmp = get0(survey_name)
  assert_that(!is.null(tmp)
              , msg = paste0(survey_name, " does not exist. Did you forget to load it? See ?set_survey"))
  assert_that(inherits(tmp, "survey.design")
              , msg = paste0(survey_name, " must be a survey.design. Is: ", class(tmp) ))
  tmp
}
