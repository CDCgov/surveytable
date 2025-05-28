.as_object_raw = function(df1, ...) {
  hh = c()
  if (!is.null(txt <- attr(df1, "title"))) {
    hh %<>% c(txt)
  }
  hh %<>% c(capture.output(as.data.frame(df1)))
  if (!is.null(txt <- attr(df1, "footer"))) {
    hh %<>% c(txt)
  }
  hh %<>% c("\n")
  hh %>% paste(collapse = "\n")
}

.print_raw = function(hh, destination = NULL, ...) {
  dest = .get_destination(destination = destination)
  assert_that(dest == ""
              , msg = "Have only implemented raw printing to the screen.")

  cat(hh)
}
