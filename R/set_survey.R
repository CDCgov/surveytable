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
#' @param aa_vr used to produce age-adjusted estimates only. The name of a
#' categorical age variable located in `design`.
#' @param aa_pop used to produce age-adjusted estimates only. A `data.frame` with
#' columns named `Level` and `Population`. `Level` must exactly match the levels
#' of `aa_vr`. `Population` is the population for that level of `aa_vr`.
#' @param ... arguments to [set_opts()].
#'
#' @family options
#' @return info about the survey
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' set_survey(namcs2019sv, mode = "NCHS")
#'
#' ## Age-adjusted estimation
#' set_survey(nhis2024a, aa_vr = "age_group_std", aa_pop = uspop_example$age_group_std)
set_survey = function(design
                      , aa_vr = NULL, aa_pop = NULL
                      , ...) {
  # In case there's an error below and we don't set a new survey,
  # don't retain the previous survey either.
  env$survey = env$aa_info = NULL
  options(surveytable.survey_label = ""
          , surveytable.age_adjusted = FALSE)

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

  ###
  tmp1 = is.null(aa_vr) + is.null(aa_pop)
  assert_that(tmp1 %in% c(0,2)
              , msg = "For age-adjusted estimates, specify both aa_vr and aa_pop.")
  if (tmp1 == 0) {
    nm = names(design$variables)
    assert_that(aa_vr %in% nm, msg = paste("Variable", aa_vr, "not in the data."))
    assert_that(is.factor(design$variables[,aa_vr])
                , msg = glue("{aa_vr}: must be factor. Is {o2s(design$variables[,aa_vr])}."))
    assert_that(is.data.frame(aa_pop)
                , msg = glue("aa_pop must be a data frame. Is {o2s(aa_pop)}."))
    assert_that( all(names(aa_pop) == c("Level", "Population"))
                 , nrow(aa_pop) >= 1
                 , is.numeric(aa_pop$Population) )
    assert_that(
      are_equal(levels(design$variables[,aa_vr]), aa_pop$Level)
      , msg = "aa_pop$Level must exactly match the levels of aa_vr."
    )

    env$aa_info = list(
      by = as.formula(paste0("~ `", aa_vr, "`"))
      , by_name = aa_vr
      , by_levels = levels(design$variables[,aa_vr])
      , population = aa_pop$Population
      , population_weights = aa_pop$Population / sum(aa_pop$Population)
    )
    options(surveytable.age_adjusted = TRUE)
    message("* Producing age-adjusted estimates.")

    # design_new = svystandardize(
    #   design = design
    #   , by = as.formula(paste0("~ `", aa_vr, "`"))
    #   , over = ~1
    #   , population = aa_pop$Population
    # )
    # attr(design_new, "label") = glue('{attr(design, "label")} (age-adjusted)')
    # design = design_new
  }

  ###
  out = data.frame(
    Variables = ncol(design$variables)
    , Observations = nrow(design$variables)
    , `Age adjustment` = .age_adjustment_label()
    , Design = design %>% capture.output %>% paste(collapse = "\n")
    , check.names = FALSE
  )
  attr(out, "title") = "Survey info"
  attr(out, "num") = c(1,2)

  options(surveytable.survey_label = attr(design, "label"))
  env$survey = design

  .check_options()
  .finalize_tab(out)
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

.get_aa_info = function() {
  assert_that(isTRUE(getOption("surveytable.age_adjusted"))
              , msg = "Age-adjusted estimates have not been requested.")
  aa_info = env$aa_info
  assert_that(is.list(aa_info)
              , all(c("by", "by_name", "by_levels", "population", "population_weights") %in% names(aa_info)))
  aa_info
}

.age_adjustment_label = function() {
  if (!isTRUE(getOption("surveytable.age_adjusted"))) {
    return("None")
  }
  aa_info = .get_aa_info()
  glue("Age-adjusted by {aa_info$by_name}: {glue_collapse(aa_info$by_levels, sep = ', ')}")
}

.age_standardize_design = function(design) {
  aa_info = .get_aa_info()
  assert_that(aa_info$by_name %in% names(design$variables)
              , msg = glue("Age-adjustment variable {aa_info$by_name} is not in the data."))
  missing_levels = setdiff(aa_info$by_levels, as.character(unique(design$variables[,aa_info$by_name])))
  assert_that(length(missing_levels) == 0
              , msg = glue("Cannot produce age-adjusted estimates: no observations for {aa_info$by_name} = {glue_collapse(missing_levels, sep = ', ')}."))

  svystandardize(
    design = design
    , by = aa_info$by
    , over = ~1
    , population = aa_info$population
  )
}
