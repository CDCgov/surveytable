.print_excel = function(obj, ...) {
  ##
  if (inherits(obj, "surveytable_table")) {
    obj = list( table1 = obj )
    class(obj) = "surveytable_list"
  }

  ##
  assert_that(inherits(obj, "surveytable_list"), length(obj) >= 1)
  assert_package("print", "openxlsx2")
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
    n_cols = ncol(df1)
    sheet_name = paste0("Table ", counter)
    wb$add_worksheet(sheet = sheet_name)

    # Add title
    title_text = attr(df1, "title")
    wb$add_data(sheet = sheet_name, x = title_text, startCol = 1, startRow = 1, colNames = FALSE)
    last_col_letter = openxlsx2::int2col(n_cols)
    wb$merge_cells(sheet = sheet_name, dims = paste0("A1:", last_col_letter, "1"))

    # Add header and table body
    wb$add_data(sheet = sheet_name, x = df1, startCol = 1, startRow = 2, colNames = TRUE)

    for (ii in attr(df1, "num")) {
      xx = LETTERS[ii]
      wb$add_numfmt(dims = glue("{xx}1:{xx}999"), numfmt = 3)
    }

    # Add footer
    footer = if("Percent" %in% names(df1)) {
      c(attr(df1, "footer"), "NOTE: Percents may not add to 100 due to rounding.", "SOURCE:")
    } else {
      c(attr(df1, "footer"), "SOURCE:")
    }
    footer_row = nrow(df1) + 3
    wb$add_data(sheet = sheet_name, x = matrix(footer, ncol = 1), startCol = 1, startRow = footer_row, colNames = FALSE)

    # Column styling
    openxlsx2::wb_set_col_widths(wb = wb, sheet = sheet_name, cols = 1:n_cols, widths = "auto")

    # Title styling
    openxlsx2::wb_add_font(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = 1, cols = 1:n_cols), name = "Arial", size = 8)
    openxlsx2::wb_add_cell_style(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = 1, cols = 1:n_cols), wrap_text = TRUE)

    # Header styling
    openxlsx2::wb_add_font(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = 2, cols = 1:n_cols), name = "Arial", size = 8)
    openxlsx2::wb_add_cell_style(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = 2, cols = 1:n_cols), wrap_text = TRUE)

    # Table body styling
    openxlsx2::wb_add_font(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = 3:(nrow(df1) + 2), cols = 1:n_cols), name = "Arial", size = 8)

    # Footer styling
    openxlsx2::wb_add_font(wb = wb, sheet = sheet_name,dims = openxlsx2::wb_dims(rows = footer_row:(footer_row + length(footer) - 1), cols = 1:n_cols),name = "Arial", size = 8)
    openxlsx2::wb_add_cell_style(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = footer_row:(footer_row + length(footer) - 1), cols = 1:n_cols), wrap_text = TRUE)

    # Border styling
    openxlsx2::wb_add_border(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = 1, cols = 1:n_cols), top_border = "none", left_border = "none", right_border = "none", bottom_border = "thin") # Under title
    openxlsx2::wb_add_border(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = 2, cols = 1:n_cols), top_border = "none", left_border = "none", right_border = "none", bottom_border = "thin") # Under header
    openxlsx2::wb_add_border(wb = wb, sheet = sheet_name, dims = openxlsx2::wb_dims(rows = nrow(df1) + 2, cols = 1:n_cols), top_border = "none", left_border = "none", right_border = "none", bottom_border = "thin") # Under last data row
  }

  ##
  wb$set_active_sheet( wb$get_sheet_names() %>% tail(-1) %>% head(1) )
  wb$save(file = file)
}
