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
  .say_printing(len = len, df1 = obj[[1]], output = "csv")

  ##
  file_exists = file.exists(file)
  if (!file_exists) {
    version = packageVersion("surveytable")
    txt = data.frame(x = c('**Tables produced by the surveytable package**'
                           , 'Date: {Sys.time()}' %>% glue()
                           , ''
                           , 'Please consider adding this or similar to your Methods section:'
                           , 'Data analyses were performed using the R package "surveytable" (version {version}).' %>% glue()
                           , 'Strashny A (2023). _surveytable: Streamlining Complex Survey Estimation and Reliability Assessment in R_. doi:10.32614/CRAN.package.surveytable, R package version {version}, <https://cdcgov.github.io/surveytable/>.' %>% glue()
                           , ''))

    write.table(txt, file = file
                , append = TRUE, row.names = FALSE
                , col.names = FALSE
                , sep = ",", qmethod = "double") %>% suppressWarnings
  }

  ##
  for (jj in 1:len) {
    df1 = obj[[jj]]
    assert_that(inherits(df1, "surveytable_table"))

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
