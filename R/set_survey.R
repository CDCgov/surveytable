#' Specify the survey to analyze
#'
#' You must specify a survey before the other functions, such as [tab()],
#' will work. To convert a `data.frame` or similar to a survey object, see [survey::svydesign()]
#' or [survey::svrepdesign()].
#'
#' Optionally, the survey can have an attribute called `label`, which is the
#' long name of the survey. Optionally, each variable in the survey can have an
#' attribute called `label`, which is the variable's long name.
#'
#' @param design a survey object, created with [survey::svydesign()] or
#' [survey::svrepdesign()]. For an unweighted survey, a `data.frame` or similar.
#' @param csv name of a CSV file
#' @param ... arguments to [set_opts()].
#'
#' @family options
#' @return info about the survey
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' set_survey(namcs2019sv, mode = "general")
set_survey = function(design, csv = getOption("surveytable.csv"), ...) {
  # In case there's an error below and we don't set a new survey,
  # don't retain the previous survey either.
  env$survey = NULL
  options(surveytable.survey_label = "")

  set_opts(...)

  if (is.string(design)) {
    label_default = design
    design %<>% get0
  } else {
    label_default = as.character(substitute(design))
  }
  assert_that(!is.null(design)
              , msg = glue("{label_default} does not exist. Did you forget to load it?"))

  if(is.null( attr(design, "label") )) {
    attr(design, "label") = label_default
  }
  assert_that(is.string(attr(design, "label")), nzchar(attr(design, "label"))
              , msg = glue("{label_default}: survey must have a label attribute."))

  if (!inherits(design, c("survey.design", "svyrep.design"))) {
    dl = attr(design, "label")
    design %<>% as.data.frame
    attr(design, "label") = dl
  }
  if (is.data.frame(design)) {
    message(glue("* {label_default}: the survey is unweighted."))
    dl = attr(design, "label")
    design = survey::svydesign(ids = ~1, probs = rep(1, nrow(design)), data = design)
    attr(design, "label") = paste(dl, "(unweighted)")
  }

  assert_that(inherits(design, c("survey.design", "svyrep.design"))
              , msg = glue("{label_default}: must be a survey object"
                           , " (survey.design or svyrep.design). Or, for an unweighted survey,"
                           , " a data.frame or similar. Is: {o2s(design)}."))

  # get rid of non-`data.frame` classes (like tbl_df), which cause problems
  design$variables %<>% as.data.frame()
  # assert_that(is.data.frame(design$variables))

  idx = which(sapply(design$variables, is.character))
  if (length(idx) > 0) {
    max_levels = getOption("surveytable.max_levels")
    for (ii in idx) {
      if ( (design$variables[,ii] %>% unique %>% length) <= max_levels ) {
        lbl = attr(design$variables[,ii], "label")
        design$variables[,ii] %<>% as.factor()
        attr(design$variables[,ii], "label") = lbl
      }
    }
  }

  if(inherits(design, "svyrep.design")) {
    assert_that(!("prob" %in% names(design)), msg = "prob already exists")
    design$prob = 1 / design$pweights
  }

  # zero weights cause issues with tab():
  # counts = svyby(frm, frm, design, unwtd.count)$counts
  # assert_that(length(neff) == length(counts))
  #
  # prob == 1 / weight
  if (any(design$prob == Inf)) {
    message(glue("* {label_default}: retaining positive weights only."))
    dl = attr(design, "label")
    dl %<>% paste("(positive weights only)")
    design %<>% survey_subset(design$prob < Inf, label = dl)
  }
  assert_that( all(design$prob > 0), all(design$prob < Inf) )

  out = data.frame(
    Variables = ncol(design$variables)
    , Observations = nrow(design$variables)
    , Design = design %>% capture.output %>% paste(collapse = "\n")
    , check.names = FALSE
  )
  attr(out, "title") = "Survey info"
  attr(out, "num") = c(1,2)

  options(surveytable.survey_label = attr(design, "label"))
  env$survey = design

  .check_options()
  .write_out(out, csv = csv)
}

.load_survey = function() {
  design = env$survey
  assert_that(!is.null(design)
      , msg = "Survey has not been specified. See ?set_survey")
  assert_that(inherits(design, c("survey.design", "svyrep.design"))
              , msg = glue("Must be a survey.design or svyrep.design. Is: {o2s(design)}."))
  assert_that( all(design$prob > 0), all(design$prob < Inf) )
  design
}
