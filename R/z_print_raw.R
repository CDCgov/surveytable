.print_raw = function(df1, destination = NULL, ...) {
  ##
  if (inherits(df1, "surveytable_list")) {
    if (length(df1) > 0) {
      for (ii in 1:length(df1)) {
        Recall(df1 = df1[[ii]], destination = destination, ...)
      }
    }
    return(invisible(NULL))
  }

  ##
  assert_that(inherits(df1, "surveytable_table"))
  dest = .get_destination(destination = destination)
  assert_that(dest == ""
              , msg = "Have only implemented raw printing to the screen.")

  ## Functions below might use as.data.frame() if the argument is not a data.frame,
  ## which creates unique column names, which is not what we want.
  class(df1) = "data.frame"

  ##
  hh = c()
  if (!is.null(txt <- attr(df1, "title"))) {
    hh %<>% c(txt)
  }
  hh %<>% c(capture.output(as.data.frame(df1)))
  if (!is.null(txt <- attr(df1, "footer"))) {
    hh %<>% c(txt)
  }
  hh %<>% c("\n") %>% paste(collapse = "\n")

  ##
  cat(hh)
}
