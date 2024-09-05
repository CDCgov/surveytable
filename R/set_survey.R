#' Specify the survey to analyze
#'
#' You must specify a survey before the other functions, such as [tab()],
#' will work. To convert a `data.frame` to a survey object, see [survey::svydesign()]
#' or [survey::svrepdesign()].
#'
#' Optionally, the survey can have an attribute called `label`, which is the
#' long name of the survey. Optionally, each variable in the survey can have an
#' attribute called `label`, which is the variable's long name.
#'
#' If you are not sure what the `mode` should be, leave it as `"default"`. Here is
#' what `mode` does:
#'
#' * `"general"` or `"default"`:
#'    * Round counts to the nearest integer -- see [set_count_int()].
#'    * Do not look for low-precision estimates.
#'    * Percentage CI's: use standard Korn-Graubard CI's.
#'
#' * `"nchs"`:
#'    * Round counts to the nearest 1,000 -- see [set_count_1k()].
#'    * Identify low-precision estimates.
#'    * Percentage CI's: adjust Korn-Graubard CI's for the number of degrees of freedom, matching the SUDAAN calculation.
#'
#' @param design either a survey object (created with [survey::svydesign()] or
#' [survey::svrepdesign()]); or, for an unweighted survey, a `data.frame`.
#' @param mode set certain options. See below.
#' @param csv name of a CSV file
#'
#' @family options
#' @return `set_survey`: info about the survey. `set_mode`: nothing.
#' @order 1
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' set_mode("general")
set_survey = function(design, mode = "default", csv = getOption("surveytable.csv")) {
  # In case there's an error below and we don't set a new survey,
  # don't retain the previous survey either.
  env$survey = NULL
  options(surveytable.survey_label = "")

  set_mode(mode = mode)

  if (is.string(design)) {
    label_default = design
    design %<>% get0
  } else {
    label_default = as.character(substitute(design))
  }

  assert_that(!is.null(design)
              , msg = paste0(label_default, " does not exist. Did you forget to load it?"))

  if(is.null( attr(design, "label") )) {
    attr(design, "label") = label_default
  }
  assert_that(is.string(attr(design, "label")), nzchar(attr(design, "label"))
              , msg = paste0(label_default, ": survey must have a label attribute."))

  if (is.data.frame(design)) {
    message(paste0("* ", label_default, ": the survey is unweighted."))
    dl = attr(design, "label")
    design = survey::svydesign(ids = ~1, probs = rep(1, nrow(design)), data = design)
    attr(design, "label") = paste(dl, "(unweighted)")
  }

  assert_that(inherits(design, c("survey.design", "svyrep.design"))
      , msg = paste0(label_default, ": must be either a survey object"
        , " (survey.design or svyrep.design) or a data.frame for an unweighted survey."
        , " Is: ", class(design)[1] ))

  # get rid of non-`data.frame` classes (like tbl_df, tbl), which cause problems for some reason
  assert_that(is.data.frame(design$variables))
  design$variables %<>% as.data.frame()

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

  out = data.frame(
    # `Survey name` = getOption("surveytable.survey_label")
    Variables = ncol(design$variables)
    , Observations = nrow(design$variables)
    , Design = design %>% capture.output %>% paste(collapse = "\n")
    , check.names = FALSE
  )
  attr(out, "title") = "Survey info"
  attr(out, "num") = c(1,2)
  .write_out(out, csv = csv)
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
