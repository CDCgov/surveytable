#' Save tables and charts to an Excel workbook
#'
#' First, initiate Excel printing with `set_opts( output = "Excel" )`. Then, use
#' the various tabulation functions to "print" / generate the tables and charts.
#' Finally, call `save_excel()` to save all of these tables and charts to a
#' single Excel file, which consists of one or more spreadsheets, one for each table or chart.
#'
#' By default, a file name is generated automatically.
#'
#' Before using Excel printing, be sure to install these packages: `openxlsx2` and `mschart`.
#'
#' @param file file name, or `NULL` (default) to generate one automatically.
#' @param overwrite overwrite file if it exists?
#' @param .temp save to a temporary location?
#'
#' @return (Nothing.)
#' @family print
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' set_opts(output = "excel")
#' total()
#' tab("AGER")
#' save_excel(file = "my_workbook.xlsx", .temp = TRUE)
#' set_opts(output = "auto")
save_excel = function(file = NULL, overwrite = FALSE, .temp = FALSE) {
  assert_that(!is.null(env$wb), inherits(env$wb, "wbWorkbook")
              , msg = "The workbook does not exist. See ?save_excel")

  ##
  title = if (env$counter <= 1) {
    env$title1
  } else {
    glue("{env$title1} and {env$counter-1} other tables")
  }
  env$wb$set_properties(title = title)

  ##
  sys_time = Sys.time()
  env$wb$add_worksheet(sheet = "About")

  ##
  xx = openxlsx2::wb_dims(from_row = 1, from_col = 1)
  env$wb$add_data(x = title, dims = xx, col_names = FALSE)

  xx = openxlsx2::wb_dims(from_row = 2, from_col = 1)
  env$wb$add_data(x = glue("File generated on {sys_time}")
                  , dims = xx, col_names = FALSE)

  ##
  xx = openxlsx2::wb_dims(from_row = 4, from_col = 1)
  env$wb$add_data(x = "Please consider adding this or similar to your Methods section:", dims = xx, col_names = FALSE)

  version = packageVersion("surveytable")
  xx = openxlsx2::wb_dims(from_row = 5, from_col = 1)
  env$wb$add_data(x = glue("Data analyses were performed using the statistical package "
                           , "“surveytable” version {version} for R.")
                  , dims = xx, col_names = FALSE)

  xx = openxlsx2::wb_dims(from_row = 6, from_col = 1)
  env$wb$add_data(x = (
    openxlsx2::fmt_txt("Strashny A (2023). ")
    + openxlsx2::fmt_txt("surveytable: Formatted Survey Estimates", italic = TRUE)
    + openxlsx2::fmt_txt(
      glue(". doi:10.32614/CRAN.package.surveytable, R package version {version}, <https://cdcgov.github.io/surveytable/>.")) )
    , dims = xx, col_names = FALSE)

  ##
  if (is.null(file) || !nzchar(file)) {
    f1 = gsub("[ .:]", "-", glue("surveytable-{sys_time}"))
    file = glue("{f1}.xlsx")
  }
  if (!.temp) {
    file_show = file %>% normalizePath(mustWork = FALSE)
  } else {
    file = file.path(tempdir(), file)
    file_show = file %>% basename()
  }

  if (!overwrite && file.exists(file)) {
    message("File {file_show} already exists. Try setting overwrite = TRUE or use a different file name.")
    return(invisible(NULL))
  }

  env$wb$save(file = file)
  message(glue("Writing {title} to {file_show}."))

  env$wb = env$title1 = env$counter = NULL
  invisible(NULL)
}
