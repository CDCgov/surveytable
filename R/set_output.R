#' Set output defaults
#'
#' `show_output()` shows the current defaults.
#'
#' @param csv     name of a CSV file or "" to turn off CSV output
#' @param screen  print to the screen?
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#'
#' @return (Nothing.)
#' @family options
#' @export
#'
#' @examples
#' set_output(csv = "out.csv")
#' show_output()
#' set_output(csv = "") # Turn off CSV output
set_output = function(csv = NULL, screen = NULL, max_levels = NULL) {
  if (!is.null(csv)) {
    assert_that(is.string(csv)
      , msg = "CSV file name must be a character string.")
    if (nzchar(csv)) {
      message(paste0("* Sending CSV output to: ", csv))
      message(paste0("* Current folder is: ", getwd(), " See ?setwd to change folder."))
      if (file.exists(csv)) {
        message("* (File already exists. Output will be appended to the end of the file.)")
      }
      message("* To turn off CSV output: set_output(csv = '')")
    } else {
      message("* Turning off CSV output.")
    }
    options(prettysurvey.csv = csv)
  }

  if (!is.null(screen)) {
    assert_that(is.flag(screen), noNA(screen))
    if (screen) {
      message("* Sending output to the screen.")
    } else {
      message("* Output is not being sent to the screen.")
    }
    options(prettysurvey.screen = screen)
  }

  if (!is.null(max_levels)) {
    assert_that(is.count(max_levels))
    message(paste0("* Setting maximum number of levels to: ", max_levels))
    options(prettysurvey.max_levels = max_levels)
  }
  message("* ?set_output for other options.")
  invisible(NULL)
}

#' @rdname set_output
#' @export
show_output = function() {
  csv = getOption("prettysurvey.csv")
  assert_that(is.string(csv)
              , msg = "CSV file name must be a character string.")
  if (nzchar(csv)) {
    message(paste0("* Sending CSV output to: ", csv))
    message(paste0("* Current folder is: ", getwd(), " See ?setwd to change folder."))
    if (file.exists(csv)) {
      message("* (File already exists. Output will be appended to the end of the file.)")
    }
    message("* To turn off CSV output: set_output(csv = '')")
  } else {
    message("* CSV output has been turned off.")
  }

  screen = getOption("prettysurvey.screen")
  assert_that(is.flag(screen), noNA(screen))
  if (screen) {
    message("* Sending output to the screen.")
  } else {
    message("* Output is not being sent to the screen.")
  }

  max_levels = getOption("prettysurvey.max_levels")
  assert_that(is.count(max_levels))
  message(paste0("* Maximum number of levels is: ", max_levels))

  invisible(NULL)
}
