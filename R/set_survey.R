#' Specify the survey to analyze
#'
#' You need to specify a survey before the other functions, such as [tab()],
#' will work.
#'
#' `opts`:
#' * `"nchs"`:
#'    * Round counts to the nearest 1,000 -- see [set_count_1k()].
#'    * Identify low-precision estimates (`surveytable.find_lpe` option is `TRUE`).
#'    * Percentage CI's: adjust Korn-Graubard CI's for the number of degrees of freedom, matching the SUDAAN calculation (`surveytable.adjust_svyciprop` option is `TRUE`).
#' * `"general":`
#'    * Round counts to the nearest integer -- see [set_count_int()].
#'    * Do not look for low-precision estimates (`surveytable.find_lpe` option is `FALSE`).
#'    * Percentage CI's: use standard Korn-Graubard CI's (`surveytable.adjust_svyciprop` option is `FALSE`).
#'
#' Optionally, the survey can have an attribute called `label`, which is the
#' long name of the survey.
#'
#' Optionally, each variable in the survey can have an attribute called `label`,
#' which is the variable's long name.
#'
#' @param design either a survey object (`survey.design` or `svyrep.design`) or a
#' `data.frame` for an unweighted survey.
#' @param opts set certain options. See below.
#' @param csv name of a CSV file
#'
#' @family options
#' @return Info about the survey.
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
set_survey = function(design, opts = "NCHS"
  , csv = getOption("surveytable.csv")) {

  ##
  opts.table = c("nchs", "general")
  idx = opts %>% tolower %>% pmatch(opts.table)
  assert_that(noNA(idx), msg = paste("Unknown value of opts:", opts))
  opts = opts.table[idx]

  if (opts == "nchs") {
    options(
      surveytable.tx_count = ".tx_count_1k"
      , surveytable.names_count = c("n", "Number (000)", "SE (000)", "LL (000)", "UL (000)")
      , surveytable.find_lpe = TRUE
      , surveytable.adjust_svyciprop = TRUE
    )
  } else if (opts == "general") {
    options(
      surveytable.tx_count = ".tx_count_int"
      , surveytable.names_count = c("n", "Number", "SE", "LL", "UL")
      , surveytable.find_lpe = FALSE
      , surveytable.adjust_svyciprop = FALSE
    )
  } else {
    stop("!!")
  }

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
