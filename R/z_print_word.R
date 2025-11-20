.print_word = function(obj, max_width = Inf, ...) {
  assert_that(max_width >= 1)

  ##
  if (inherits(obj, "surveytable_table")) {
    obj = list( table1 = obj )
    class(obj) = "surveytable_list"
  }

  ##
  assert_that(inherits(obj, "surveytable_list"), length(obj) >= 1)
  assert_package("print", "officer")
  assert_package("print", "flextable")
  file = getOption("surveytable.file")
  assert_that(is.string(file), nzchar(file))

  ##
  len = length(obj)
  .say_printing(len = len, df1 = obj[[1]], output = "word")

  ##
  file_exists = file.exists(file)
  doc = if (file_exists) {
    officer::read_docx(path = file) %>% officer::set_doc_properties(
      creator = "surveytable"
      , description = "tables, charts, estimates, R, survey, surveytable"
    )
  } else {
    officer::read_docx() %>% officer::set_doc_properties(
      creator = "surveytable"
      , title = .get_title(obj[[1]])
      , description = "tables, charts, estimates, R, survey, surveytable"
    )
  }
  if (!file_exists) {
    version = packageVersion("surveytable")

    doc %<>% officer::body_add_fpar(value = officer::fpar(officer::ftext("Tables produced by the surveytable package", officer::fp_text_lite(bold = TRUE)))) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( glue("Date: {Sys.time()}") ))) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( "" ))) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( "Please consider adding this or similar to your Methods section:" ))) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( "" ))) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( glue("Data analyses were performed using the R package "
                                                                        , "\u201Csurveytable\u201D (version {version}).") ))) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( "" ))) %>%
      officer::body_add_fpar(value = officer::fpar(
        officer::ftext("Strashny A (2023). ")
        , officer::ftext("surveytable: Streamlining Complex Survey Estimation and Reliability Assessment in R", officer::fp_text_lite(italic = TRUE))
        , officer::ftext(glue(". doi:10.32614/CRAN.package.surveytable, R package version {version}, <"))
        , officer::hyperlink_ftext(text = "https://cdcgov.github.io/surveytable/", href = "https://cdcgov.github.io/surveytable/"
                                   , prop = officer::fp_text_lite(underlined = TRUE, color = "blue"))
        , officer::ftext(">.")
      )) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( "" ))) %>%
      officer::body_add_fpar(value = officer::fpar(officer::ftext( "" )))
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
