.print_csv = function(obj, ...) {
  ##
  if (inherits(obj, "surveytable_table")) {
    obj = list( table1 = obj )
    class(obj) = "surveytable_list"
  }

  ##
  assert_that(inherits(obj, "surveytable_list"), length(obj) >= 1)
  file = getOption("surveytable.file")
  assert_that(is.string(file), nzchar(file))

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
  message(glue("* Printing {title} to CSV file {getOption('surveytable.file_show')}."))

  ##
  for (jj in 1:len) {
    df1 = obj[[jj]]
    assert_that(inherits(df1, "surveytable_table"))
    ##
    ## Functions below might use as.data.frame() if the argument is not a data.frame,
    ## which creates unique column names, which is not what we want.
    class(df1) = "data.frame"

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
