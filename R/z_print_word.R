.print_word = function(obj, ...) {
  ##
  if (inherits(obj, "surveytable_table")) {
    obj = list( table1 = obj )
    class(obj) = "surveytable_list"
  }

  ##
  assert_that(inherits(obj, "surveytable_list"), length(obj) >= 1)
  assert_package("print", "officer")
  file = getOption("surveytable.file")
  assert_that(is.string(file), nzchar(file))


  doc = officer::read_docx()

  ## HERE

  ##
  ftl = list()
  for (ii in 1:length(obj)) {
    ftl[[ii]] = obj[[ii]] %>% .print_flextable_1()
  }



  ##
  wb = if (file.exists(file)) {
    wb = openxlsx2::wb_load(file)
    wb$set_properties(
      creator = "surveytable"
      , keywords = "tables, charts, estimates, R, survey, surveytable"
    )
  } else {
    openxlsx2::wb_workbook(
      creator = "surveytable"
      , title = .get_title(obj[[1]])
      , theme = "Facet"
      , keywords = "tables, charts, estimates, R, survey, surveytable"
    )
  }
  counter = length(wb$sheet_names)

  ##
  len = length(obj)
  t1 = .get_title(obj[[1]])
  title = if (len == 1) {
    t1
  } else if (len == 2) {
    glue("{t1} and {len-1} other table")
  } else {
    glue("{t1} and {len-1} other tables")
  }
  message(glue("* Printing {title} to Excel workbook {getOption('surveytable.file_show')}."))

  ##
  for (jj in 1:len) {
    counter = counter + 1
    df1 = obj[[jj]]
    assert_that(inherits(df1, "surveytable_table"))
    df1 %<>% .fix_names()

    ##
    wb$add_worksheet(sheet = glue("Table {counter}"))
    wb$add_data_table(x = df1)$set_col_widths(
      cols = 1:ncol(df1), widths = 15)
    for (ii in attr(df1, "num")) {
      xx = LETTERS[ii]
      wb$add_numfmt(dims = glue("{xx}1:{xx}999"), numfmt = 3)
    }
    wb$add_data(x = attr(df1, "title")
                , dims = openxlsx2::wb_dims(from_row = nrow(df1) + 2, from_col = 1)
                , col_names = FALSE)
    wb$add_data(x = attr(df1, "footer")
                , dims = openxlsx2::wb_dims(from_row = nrow(df1) + 3, from_col = 1)
                , col_names = FALSE)

    ##
    wb %<>% .add_chart1(df1 = df1, sw = "Number", jj = counter)
    wb %<>% .add_chart1(df1 = df1, sw = "Percent", jj = counter)
    wb %<>% .add_chart1(df1 = df1, sw = "Rate", jj = counter)
  }

  ##
  wb$save(file = file)
}

