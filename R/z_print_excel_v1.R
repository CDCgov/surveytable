.print_excel_v1 = function(obj, ...) {
  ##
  if (inherits(obj, "surveytable_table")) {
    obj = list( table1 = obj )
    class(obj) = "surveytable_list"
  }

  ##
  assert_that(inherits(obj, "surveytable_list"), length(obj) >= 1)
  assert_package("print", "openxlsx2")
  assert_package("print", "mschart")
  file = getOption("surveytable.file")
  assert_that(is.string(file), nzchar(file))

  ##
  len = length(obj)
  .say_printing(len = len, df1 = obj[[1]], output = "excel")

  ##
  file_exists = file.exists(file)
  wb = if (file_exists) {
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
  if (!file_exists) {
    wb$add_worksheet(sheet = "About")

    ##
    xx = openxlsx2::wb_dims(from_row = 1, from_col = 1)
    wb$add_data(x = openxlsx2::fmt_txt("Tables produced by the surveytable package", bold = TRUE)
                , dims = xx, col_names = FALSE)

    ##
    xx = openxlsx2::wb_dims(from_row = 2, from_col = 1)
    wb$add_data(x = glue("Date: {Sys.time()}")
                , dims = xx, col_names = FALSE)

    ##
    xx = openxlsx2::wb_dims(from_row = 4, from_col = 1)
    wb$add_data(x = "Please consider adding this or similar to your Methods section:", dims = xx, col_names = FALSE)

    version = packageVersion("surveytable")
    xx = openxlsx2::wb_dims(from_row = 5, from_col = 1)
    wb$add_data(x = glue("Data analyses were performed using the R package "
                         , "\u201Csurveytable\u201D (version {version}).")
                , dims = xx, col_names = FALSE)

    xx = openxlsx2::wb_dims(from_row = 6, from_col = 1)
    wb$add_data(x = (
      openxlsx2::fmt_txt("Strashny A (2023). ")
      + openxlsx2::fmt_txt("surveytable: Streamlining Complex Survey Estimation and Reliability Assessment in R", italic = TRUE)
      + openxlsx2::fmt_txt(
        glue(". doi:10.32614/CRAN.package.surveytable, R package version {version}, <https://cdcgov.github.io/surveytable/>.")) )
      , dims = xx, col_names = FALSE)
  }
  counter = if(file_exists) {
    length(wb$sheet_names)
  } else {
    0
  }

  ##
  for (jj in 1:len) {
    counter = counter + 1
    df1 = obj[[jj]]
    assert_that(inherits(df1, "surveytable_table"))

    ## Functions below might use as.data.frame() if the argument is not a data.frame,
    ## which creates unique column names, which is not what we want.
    class(df1) = "data.frame"

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
  wb$set_active_sheet( wb$get_sheet_names() %>% tail(-1) %>% head(1) )
  wb$save(file = file)
}

.add_chart1 = function(wb, df1, sw, jj) {
  idx = which(names(df1) %>% startsWith(sw))
  if (length(idx) > 0 && nrow(df1) > 1) {
    assert_that(length(idx) == 1)
    y_name = names(df1)[idx]
    x_name = names(df1)[1]

    ch1 = mschart::ms_barchart(data = df1, x = x_name, y = y_name)
    ch1 %<>% mschart::chart_labels(title = .get_title(df1))
    wb$add_worksheet(sheet = glue("{sw} {jj}")
                     )$add_mschart(graph = ch1, dims = "A1:Q21")
  }
  wb
}

.fix_names = function(df1) {
  names(df1) = names(df1) %>% make.unique()
  df1
}

.say_printing = function(len, df1, output) {
  ##
  assert_that(output %in% c("excel", "word", "csv"))
  type = switch(output
                , excel = "Excel workbook"
                , word = "Word document"
                , csv = "CSV file")

  ##
  t1 = .get_title(df1)
  title = if (len == 1) {
    t1
  } else if (len == 2) {
    glue("{t1} and {len-1} other table")
  } else {
    glue("{t1} and {len-1} other tables")
  }

  ##
  message(glue("* Printing {title} to {type} {getOption('surveytable.file_show')}."))
}

.get_title = function(df1) {
  xx = attr(df1, "title")
  if (!is.null(xx) && nzchar(xx)) {
    xx
  } else {
    "Unknown table"
  }
}
