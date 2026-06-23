.print_excel = function(obj, ...) {
  ##
  obj = .astra_as_list(obj)
  assert_package("print", "openxlsx2")
  file = .astra_file()

  ##
  len = length(obj)
  .say_printing(len = len, df1 = obj[[1]], output = "excel")

  ##
  file_exists = file.exists(file)
  producer = .astra_producer()
  wb = if (file_exists) {
    wb = openxlsx2::wb_load(file)
    wb$set_properties(
      creator = producer$package
      , keywords = producer$keywords
    )
  } else {
    openxlsx2::wb_workbook(
      creator = producer$package
      , title = .get_title(obj[[1]])
      , theme = "Facet"
      , keywords = producer$keywords
    )
  }
  if (!file_exists) {
    wb$add_worksheet(sheet = "About")
    about = .astra_about_excel()
    for (ii in seq_along(about)) {
      xx = openxlsx2::wb_dims(from_row = ii, from_col = 1)
      wb$add_data(x = about[[ii]], dims = xx, col_names = FALSE)
    }
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
    .astra_assert_table(df1)
    ## Functions below might use as.data.frame() if the argument is not a data.frame,
    ## which creates unique column names, which is not what we want.
    df1 = .astra_as_data_frame(df1)

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
