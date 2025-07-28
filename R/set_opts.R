#' Set certain options
#'
#' `set_opts()` sets certain package options. To view these options, use `show_opts()`.
#' For more advanced control and detailed customization, experienced  users can
#' also employ [options()] and [show_options()] (refer to [surveytable-options]
#' for further information).
#'
#' If you are not setting a particular option, leave it as `NULL`.
#'
#' `mode` can be either `"general"` or `"NCHS"` and has the following meaning:
#'
#' * `"general"`:
#'    * Round counts to the nearest integer -- same as `count = "int"`.
#'    * Do not look for low-precision estimates -- same as `lpe = FALSE`.
#'    * Percentage CI's: use standard Korn-Graubard CI's -- same as `adj = "none"`.
#'
#' * `"nchs"`:
#'    * Round counts to the nearest 1,000 -- same as `count = "1k"`.
#'    * Identify low-precision estimates -- same as `lpe = TRUE`.
#'    * Percentage CI's: adjust Korn-Graubard CI's for the number of degrees of
#'    freedom, matching the SUDAAN calculation -- same as `adj = "nchs"`. This
#'    is appropriate for some, but not all, NCHS data systems. For some NCHS
#'    data systems, such as NHIS, you might need to set `adj` to one of the other values.
#'
#' `adj` specifies the adjustment to the Korn and Graubard confidence intervals for
#' proportions. See `svyciprop_adjusted()` for details.
#'
#' `output` determines how the output is printed:
#'
#' * `"auto"` (default): automatically select the table-making package, depending on the
#' destination (such as screen, HTML, or PDF / LaTeX).
#' * `"huxtable"`, `"gt"`, or `"kableExtra"`: use this table-making package. Be sure
#' that this package is installed.
#' * `"raw"`: unformatted / raw output. This is useful for getting lots of significant digits.
#' * `"Excel"`: print to an Excel workbook. Please specify the name of an Excel file using
#' the `file` argument. Before using Excel printing, please be sure to install these
#' packages: `openxlsx2` and `mschart`.
#' * `"CSV"`: print to a comma-separated values (CSV) file. Please specify the name of a
#' CSV file using the `file` argument.
#'
#' @param reset reset all options to their default values?
#' @param mode `"general"` or `"NCHS"`. See below for details.
#' @param adj adjustment to the Korn and Graubard confidence intervals for proportions. See
#' `svyciprop_adjusted()` for details.
#' @param output specify how the output is printed: `"auto"` (default); `"huxtable"`, `"gt"`, or
#' `"kableExtra"`; `"raw"`; `"Excel"` or `"CSV"`. If `output` is `"Excel"` or `"CSV"`, must also specify
#' `file`. If `output` is `"Excel"`, be sure to install `openxlsx2` and `mschart`.
#' @param file file name (see `output`).
#' @param .file_temp place `file` in a temporary folder?
#' @param count round counts to the nearest integer (`"int"`) or one thousand (`"1k"`).
#' @param lpe identify low-precision estimates?
#' @param drop_na drop missing values (`NA`)? Categorical variables only.
#' @param max_levels a categorical variable can have at most this many levels.
#' Used to avoid printing huge tables.
#'
#' @return (Nothing.)
#' @family options, print
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#'
#' # Round counts to the nearest one thousand:
#' set_opts(count = "1k")
#' tab("AGER")
#' set_opts(count = "int")
#'
#' show_opts()
set_opts = function(
    reset = NULL
    , mode = NULL
    , adj = NULL
    , output = NULL
    , file = NULL
    , .file_temp = NULL
    , count = NULL
    , lpe = NULL
    , drop_na = NULL
    , max_levels = NULL
    ) {

  #### !!! If making changes, update: .onLoad(), set_opts(), show_opts(), .check_options()

  ## Reset has to go ahead of the other options
  if (!is.null(reset)) {
    assert_that(is.flag(reset), reset %in% c(TRUE, FALSE))
    if (reset) {
      message("* Resetting all options to their default values.")
      env$survey = NULL
      .onLoad()
    }
  }

  ## Mode has to go ahead of the other options
  if (!is.null(mode)) {
    mode %<>% .mymatch(c("nchs", "general"))
    if (mode == "nchs") {
      message("* Mode: NCHS.")
      options(surveytable.svyciprop_adj = "nchs"
        , surveytable.tx_count = ".tx_count_1k"
        , surveytable.names_count = c("n", "Number (000)", "SE (000)", "LL (000)", "UL (000)")
        , surveytable.find_lpe = TRUE)
    } else if (mode == "general") {
      message("* Mode: General.")
      options(surveytable.svyciprop_adj = "none"
        , surveytable.tx_count = ".tx_count_int"
        , surveytable.names_count = c("n", "Number", "SE", "LL", "UL")
        , surveytable.find_lpe = FALSE)
    }
  }

  if (!is.null(adj)) {
    adj %<>% .mymatch(c("none", "nchs", "nhis"))
    if (adj == "none") {
      message("* Korn and Graubard confidence intervals for proportions.")
    } else if (adj == "nchs") {
      message("* Korn and Graubard confidence intervals for proportions with an adjustment that might be required by some (though not all) NCHS data systems.")
    } else if (adj == "nhis") {
      message("* Korn and Graubard confidence intervals for proportions with an adjustment that might be required by NHIS.")
    }
    options(surveytable.svyciprop_adj = adj)
  }

  if (!is.null(output)) {
    if (getOption("surveytable.print") == ".print_excel") .print_excel_finish()

    output %<>% .mymatch(c("huxtable", "gt", "kableExtra", "auto", "raw", "excel", "csv"))
    if (output == "auto") {
      message("* Printing with huxtable for screen, gt for HTML, or kableExtra for PDF.")
      options(surveytable.raw = FALSE
              , surveytable.print = ".print_auto"
              , surveytable.file = "", surveytable.file_show = "")
    } else if (output %in% c("huxtable", "gt", "kableExtra") ) {
      message(glue("* Printing with {output}."))
      options(surveytable.raw = FALSE
              , surveytable.print = glue(".print_{output}")
              , surveytable.file = "", surveytable.file_show = "")
    } else if (output == "raw") {
      message("* Generating unformatted / raw output.")
      options(surveytable.raw = TRUE
              , surveytable.print = ".print_raw"
              , surveytable.file = "", surveytable.file_show = "")
    } else if (output %in% c("excel", "csv")) {
      .set_output_file(output = output, file = file, .file_temp = .file_temp)
    }
  }

  if (!is.null(count)) {
    if (getOption("surveytable.raw")) {
      message("* To perform rounding, first turn off raw output.")
    } else {
      count %<>% .mymatch(c("int", "1k"))
      if (count == "int") {
        message("* Rounding counts to the nearest integer.")
        options(surveytable.tx_count = ".tx_count_int"
                , surveytable.names_count = c("n", "Number", "SE", "LL", "UL"))
      } else if (count == "1k") {
        message("* Rounding counts to the nearest thousand.")
        options(surveytable.tx_count = ".tx_count_1k"
                , surveytable.names_count = c("n", "Number (000)", "SE (000)", "LL (000)", "UL (000)"))
      }
    }
  }

  if (!is.null(lpe)) {
    assert_that(is.flag(lpe), lpe %in% c(TRUE, FALSE))
    if (lpe) {
      message("* Identifying low-precision estimates.")
    } else {
      message("* Not identifying low-precision estimates.")
    }
    options(surveytable.find_lpe = lpe)
  }

  if (!is.null(drop_na)) {
    assert_that(is.flag(drop_na), drop_na %in% c(TRUE, FALSE))
    if (drop_na) {
      message("* Dropping missing values. Showing knowns only.")
    } else {
      message("* Retaining missing values.")
    }
    options(surveytable.drop_na = drop_na)
  }

  if (!is.null(max_levels)) {
    assert_that(is.count(max_levels))
    message(paste0("* Setting maximum number of levels to: ", max_levels))
    options(surveytable.max_levels = max_levels)
  }

  .check_options()
  invisible(NULL)
}

.set_output_file = function(output, file, .file_temp) {
  assert_that(output %in% c("excel", "csv"))
  type = switch(output
                , excel = "Excel"
                , csv = "CSV")
  extension = switch(output
                     , excel = ".xlsx"
                     , csv = ".csv")
  assert_that(is.string(file), nzchar(file)
              , msg = glue("For {type} printing, please specify a file name using the file argument."))
  if (!endsWith(tolower(file), extension)) {
    file = glue("{file}{extension}")
  }
  if (!isTRUE(.file_temp)) {
    file %<>% normalizePath(mustWork = FALSE)
    file_show = file
  } else {
    file = file.path(tempdir(), file)
    file_show = file %>% basename()
  }
  message(glue("* Printing to {type} file {file_show}."))
  if (file.exists(file)) {
    message("* NOTE: file already exists!")
  }
  options(surveytable.raw = FALSE
          , surveytable.print = glue(".print_{output}")
          , surveytable.file = file, surveytable.file_show = file_show)
}

