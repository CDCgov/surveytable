.print_screen = function(df1, destination = NULL, ...) {
  ##
  if (.astra_is_list(df1)) {
    if (length(df1) > 0) {
      for (ii in 1:length(df1)) {
        Recall(df1 = df1[[ii]], destination = destination, ...)
      }
    }
    return(invisible(NULL))
  }

  ##
  .astra_assert_table(df1)
  dest = .get_destination(destination = destination)
  assert_that(dest == ""
              , msg = "Have only implemented screen printing to the screen.")

  ## Functions below might use as.data.frame() if the argument is not a data.frame,
  ## which creates unique column names, which is not what we want.
  df1 = .astra_as_data_frame(df1)

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
