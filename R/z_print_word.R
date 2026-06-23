.print_word = function(obj, max_width = Inf, ...) {
  assert_that(max_width >= 1)

  ##
  obj = .astra_as_list(obj)
  assert_package("print", "officer")
  assert_package("print", "flextable")
  file = .astra_file()

  ##
  len = length(obj)
  .say_printing(len = len, df1 = obj[[1]], output = "word")

  ##
  file_exists = file.exists(file)
  producer = .astra_producer()
  doc = if (file_exists) {
    officer::read_docx(path = file) %>% officer::set_doc_properties(
      creator = producer$package
      , description = producer$keywords
    )
  } else {
    officer::read_docx() %>% officer::set_doc_properties(
      creator = producer$package
      , title = .get_title(obj[[1]])
      , description = producer$keywords
    )
  }
  if (!file_exists) {
    about = .astra_about_word()
    for (ii in seq_along(about)) {
      doc %<>% officer::body_add_fpar(value = about[[ii]])
    }
  }

  ##
  for (jj in 1:len) {
    ## class(df1) = "data.frame" in .print_flextable_1()
    ft = obj[[jj]] %>% .print_flextable_1() %>% flextable::fit_to_width(max_width = max_width)
    doc %<>% flextable::body_add_flextable(ft)
    # if (jj < len) {
    #   doc %<>% officer::body_add_break()
    # }
  }

  ##
  fn = utils::getFromNamespace("print.rdocx", "officer")
  fn(doc, target = file, ...)
}
