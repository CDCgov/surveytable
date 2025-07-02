.print_excel = function(obj, ...) {
  ##
  if (inherits(obj, "surveytable_table")) {
    obj = list( table1 = obj )
    class(obj) = "surveytable_list"
  }

  ##
  assert_package("print", "openxlsx2")
  assert_package("print", "mschart")
  assert_that(inherits(obj, "surveytable_list"))

  ##
  if (is.null(env$wb)) {
    env$wb = openxlsx2::wb_workbook(
      creator = "surveytable"
      , theme = "Facet"
      , keywords = "tables, charts, estimates, R, survey, surveytable"
    )

    len = length(obj)
    env$title1 = if (len == 0) {
      "Blank workbook"
    } else {
      .get_title(obj[[1]])
    }

    env$counter = 0
  }

  ##
  len = length(obj)
  if (len == 0) return(invisible(NULL))

  t1 = .get_title(obj[[1]])
  title = if (len == 1) {
    t1
  } else {
    glue("{t1} and {len-1} other tables")
  }

  ##
  for (jj in 1:len) {
    env$counter = env$counter + 1
    df1 = obj[[jj]]
    assert_that(inherits(df1, "surveytable_table"))
    df1 %<>% .fix_names()

    ##
    env$wb$add_worksheet(sheet = glue("Table {env$counter}"))
    env$wb$add_data_table(x = df1)$set_col_widths(
      cols = 1:ncol(df1), widths = 15)
    for (ii in attr(df1, "num")) {
      xx = LETTERS[ii]
      env$wb$add_numfmt(dims = glue("{xx}1:{xx}999"), numfmt = 3)
    }
    env$wb$add_data(x = attr(df1, "title")
                , dims = openxlsx2::wb_dims(from_row = nrow(df1) + 2, from_col = 1)
                , col_names = FALSE)
    env$wb$add_data(x = attr(df1, "footer")
                , dims = openxlsx2::wb_dims(from_row = nrow(df1) + 3, from_col = 1)
                , col_names = FALSE)

    ##
    env$wb %<>% .add_chart1(df1 = df1, sw = "Number", jj = env$counter)
    env$wb %<>% .add_chart1(df1 = df1, sw = "Percent", jj = env$counter)
    env$wb %<>% .add_chart1(df1 = df1, sw = "Rate", jj = env$counter)
  }
  message(glue("Printing {title} to an Excel workbook. Use save_excel() to save that workbook to a file."))
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

.get_title = function(df1) {
  xx = attr(df1, "title")
  if (!is.null(xx) && nzchar(xx)) {
    xx
  } else {
    "Unknown table"
  }
}
