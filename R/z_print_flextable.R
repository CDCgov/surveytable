.print_flextable = function(df1, ...) {
  ##
  if (inherits(df1, "surveytable_list")) {
    if (length(df1) > 0) {
      for (ii in 1:length(df1)) {
        Recall(df1 = df1[[ii]], ...)
      }
    }
    return(invisible(NULL))
  }

  ##
  hh = df1 %>% .print_flextable_1()
  fn = utils::getFromNamespace("print.flextable", "flextable")
  fn(hh, ...)
}

.print_flextable_1 = function(df1, ...) {
  ##
  assert_package("print", "flextable")
  assert_that(inherits(df1, "surveytable_table"))

  ## Functions below might use as.data.frame() if the argument is not a data.frame,
  ## which creates unique column names, which is not what we want.
  class(df1) = "data.frame"

  ##
  orig_labels = names(df1)
  unique_keys = make.unique(orig_labels)
  names(df1) = unique_keys
  label_map = setNames(orig_labels, unique_keys)

  ##
  flextable::flextable(df1) %>%
    flextable::set_caption(caption = attr(df1, "title")) %>%
    flextable::add_footer_lines(values = attr(df1, "footer")) %>%
    flextable::set_header_labels(values = label_map) %>%
    flextable::autofit()
}
