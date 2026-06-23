.print_csv = function(obj, ...) {
  ##
  obj = .astra_as_list(obj)
  file = .astra_file()

  ##
  len = length(obj)
  .say_printing(len = len, df1 = obj[[1]], output = "csv")

  ##
  file_exists = file.exists(file)
  if (!file_exists) {
    txt = data.frame(x = .astra_about_lines(markdown = TRUE))

    write.table(txt, file = file
                , append = TRUE, row.names = FALSE
                , col.names = FALSE
                , sep = ",", qmethod = "double") %>% suppressWarnings
  }

  ##
  for (jj in 1:len) {
    df1 = obj[[jj]]
    .astra_assert_table(df1)

    ## Functions below might use as.data.frame() if the argument is not a data.frame,
    ## which creates unique column names, which is not what we want.
    df1 = .astra_as_data_frame(df1)

    if (!is.null(txt <- attr(df1, "title"))) {
      write.table(txt, file = file
                  , append = TRUE, row.names = FALSE
                  , col.names = FALSE
                  , sep = ",", qmethod = "double") %>% suppressWarnings
    }
    write.table(df1, file = file
                , append = TRUE, row.names = FALSE
                , sep = ",", qmethod = "double") %>% suppressWarnings
    if (!is.null(txt <- attr(df1, "footer"))) {
      write.table(txt, file = file
                  , append = TRUE, row.names = FALSE
                  , col.names = FALSE
                  , sep = ",", qmethod = "double") %>% suppressWarnings
    }
    cat("\n", file = file, append = TRUE)
  }
}
