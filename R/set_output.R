#' Set output defaults
#'
#' `show_output()` shows the current defaults.
#'
#' @param csv     name of a CSV file or "" to turn off CSV output
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#'
#' @return (Nothing.)
#' @family options
#' @export
#'
#' @examples
#' tmp_file = tempfile(fileext = ".csv")
#' suppressMessages( set_output(csv = tmp_file) )
#' set_output(csv = "") # Turn off CSV output
set_output = function(csv = NULL, max_levels = NULL) {
  # If making changes, update .onLoad()
  if (!is.null(csv)) {
    assert_that(is.string(csv)
      , msg = "CSV file name must be a character string.")
    if (nzchar(csv)) {
      message(paste0("* Sending CSV output to: ", csv))
      if (file.exists(csv)) {
        message("* (File already exists. Output will be appended to the end of the file.)")
      }
      message("* To turn off CSV output: set_output(csv = '')")
    } else {
      message("* Turning off CSV output.")
    }
    options(surveytable.csv = csv)
  }

  if (!is.null(max_levels)) {
    assert_that(is.count(max_levels))
    message(paste0("* Setting maximum number of levels to: ", max_levels))
    options(surveytable.max_levels = max_levels)
  }
  message("* ?set_output for other options.")
  invisible(NULL)
}

#' @rdname set_output
#' @export
show_output = function() {
  csv = getOption("surveytable.csv")
  assert_that(is.string(csv)
              , msg = "CSV file name must be a character string.")
  if (nzchar(csv)) {
    message(paste0("* Sending CSV output to: ", csv))
    if (file.exists(csv)) {
      message("* (File already exists. Output will be appended to the end of the file.)")
    }
    message("* To turn off CSV output: set_output(csv = '')")
  } else {
    message("* CSV output has been turned off.")
  }

  max_levels = getOption("surveytable.max_levels")
  assert_that(is.count(max_levels))
  message(paste0("* Maximum number of levels is: ", max_levels))

  invisible(NULL)
}
