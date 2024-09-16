#' Set certain options
#'
#' `set_opts()` sets certain options. `show_opts()` shows the options that have
#' been set. More advanced users can also use [options()] and [show_options()] for
#' more detailed control.
#'
#' If you are not setting a particular option, leave it as `NULL`.
#'
#' `mode` can be either `"general"` or `"NCHS"` and has the following meaning:
#'
#' * `"general"`:
#'    * Round counts to the nearest integer -- same as `count = "int"`.
#'    * Do not look for low-precision estimates -- same as `lpe = FALSE`.
#'    * Percentage CI's: use standard Korn-Graubard CI's.
#'
#' * `"nchs"`:
#'    * Round counts to the nearest 1,000 -- same as `count = "1k"`.
#'    * Identify low-precision estimates -- same as `lpe = TRUE`.
#'    * Percentage CI's: adjust Korn-Graubard CI's for the number of degrees of
#'    freedom, matching the SUDAAN calculation.
#'
#' @param mode `"general"` or `"NCHS"`. See below for details.
#' @param count round counts to the nearest: integer (`"int"`) or one thousand (`"1k"`)
#' @param lpe identify low-precision estimates?
#' @param drop_na drop missing values (`NA`)? Categorical variables only.
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param csv     name of a CSV file or `""` to turn off CSV output
#'
#' @return (Nothing.)
#' @family options
#' @export
#'
#' @examples
#' # Send output to a CSV file:
#' file_name = tempfile(fileext = ".csv")
#' suppressMessages( set_opts(csv = file_name) )
#' set_survey(namcs2019sv)
#' tab("AGER")
#' set_opts(csv = "") # Turn off CSV output
#'
#' show_opts()
set_opts = function(
    mode = NULL
    , count = NULL
    , lpe = NULL
    , drop_na = NULL, max_levels = NULL, csv = NULL) {
  # If making changes, update .onLoad()

  ## Mode has to go ahead of the other options
  if (!is.null(mode)) {
    mode %<>% .mymatch(c("nchs", "general"))
    if (mode == "nchs") {
      message("* Mode: NCHS.")
      options(surveytable.tx_count = ".tx_count_1k"
        , surveytable.names_count = c("n", "Number (000)", "SE (000)", "LL (000)", "UL (000)")
        , surveytable.find_lpe = TRUE
        , surveytable.adjust_svyciprop = TRUE)
    } else if (mode == "general") {
      message("* Mode: General.")
      options(surveytable.tx_count = ".tx_count_int"
        , surveytable.names_count = c("n", "Number", "SE", "LL", "UL")
        , surveytable.find_lpe = FALSE
        , surveytable.adjust_svyciprop = FALSE)
    }
  }

  if (!is.null(count)) {
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

  if (!is.null(csv)) {
    assert_that(is.string(csv)
      , msg = "CSV file name must be a character string.")
    if (nzchar(csv)) {
      message(paste0("* Sending CSV output to: ", csv))
      if (file.exists(csv)) {
        message("* (File already exists. Output will be appended to the end of the file.)")
      }
      message("* To turn off CSV output: set_opts(csv = '')")
    } else {
      message("* Turning off CSV output.")
    }
    options(surveytable.csv = csv)
  }

  invisible(NULL)
}

#' @rdname set_opts
#' @export
show_opts = function() {

  tx_count = getOption("surveytable.tx_count")
  assert_that(is.string(tx_count), nzchar(tx_count))
  switch(tx_count
         , ".tx_count_int" = "* Rounding counts to the nearest integer."
         , ".tx_count_1k" = "* Rounding counts to the nearest thousand."
         , ".tx_count_none" = "* Not rounding counts."
         , " * Count rounding function: " %>% paste0(tx_count)
         ) %>% message

  lpe = getOption("surveytable.find_lpe")
  assert_that(is.flag(lpe), lpe %in% c(TRUE, FALSE))
  if (lpe) {
    message("* Identifying low-precision estimates.")
  } else {
    message("* Not identifying low-precision estimates.")
  }

  xx = getOption("surveytable.adjust_svyciprop")
  assert_that(is.flag(xx), xx %in% c(TRUE, FALSE))
  if (xx) {
    message("* Using adjusted Korn-Graubard CI's.")
  } else {
    message("* Using standard Korn-Graubard CI's.")
  }

  drop_na = getOption("surveytable.drop_na")
  assert_that(is.flag(drop_na), drop_na %in% c(TRUE, FALSE))
  if (drop_na) {
    message("* Dropping missing values. Showing knowns only.")
  } else {
    message("* Retaining missing values.")
  }

  max_levels = getOption("surveytable.max_levels")
  assert_that(is.count(max_levels))
  message(paste0("* Maximum number of levels is: ", max_levels))

  csv = getOption("surveytable.csv")
  assert_that(is.string(csv)
              , msg = "CSV file name must be a character string.")
  if (nzchar(csv)) {
    message(paste0("* Sending CSV output to: ", csv))
    if (file.exists(csv)) {
      message("* (File already exists. Output will be appended to the end of the file.)")
    }
    message("* To turn off CSV output: set_opts(csv = '')")
  } else {
    message("* CSV output has been turned off.")
  }

  invisible(NULL)
}
