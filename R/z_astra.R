.astra_is_table = function(x) {
  inherits(x, "astra_table")
}

.astra_is_list = function(x) {
  inherits(x, "astra_list")
}

.astra_assert_table = function(x) {
  assert_that(.astra_is_table(x))
  invisible(NULL)
}

.astra_assert_list = function(x) {
  assert_that(.astra_is_list(x), length(x) >= 1)
  invisible(NULL)
}

.astra_as_list = function(x) {
  if (.astra_is_table(x)) {
    x = list(table1 = x)
    class(x) = "astra_list"
  }
  .astra_assert_list(x)
  x
}

.astra_as_data_frame = function(x) {
  class(x) = "data.frame"
  x
}

.astra_file = function() {
  file = getOption("astra.file")
  assert_that(is.string(file), nzchar(file))
  file
}

.astra_file_show = function() {
  file_show = getOption("astra.file_show")
  assert_that(is.string(file_show))
  file_show
}

.astra_print_for_output = function(output) {
  assert_that(is.string(output), nzchar(output))
  switch(output
         , "auto" = ".print_auto"
         , "huxtable" = ".print_huxtable"
         , "gt" = ".print_gt"
         , "kableextra" = ".print_kableextra"
         , "flextable" = ".print_flextable"
         , "screen" = ".print_screen"
         , "excel" = ".print_excel"
         , "excel_v1" = ".print_excel_v1"
         , "word" = ".print_word"
         , "csv" = ".print_csv"
         , stop(glue('Unknown output: "{output}"'), call. = FALSE))
}

.astra_print_info = function(print = getOption("astra.print")) {
  if (is.null(print)) {
    print = ".print_auto"
  }
  assert_that(is.string(print), nzchar(print))

  info = switch(print
                , ".print_auto" = list(
                  output = "auto"
                  , raw = FALSE
                  , message = "* Printing with huxtable for screen, gt for HTML, or kableExtra for PDF."
                )
                , ".print_huxtable" = list(
                  output = "huxtable"
                  , raw = FALSE
                  , message = "* Printing with huxtable."
                )
                , ".print_gt" = list(
                  output = "gt"
                  , raw = FALSE
                  , message = "* Printing with gt."
                )
                , ".print_kableextra" = list(
                  output = "kableextra"
                  , raw = FALSE
                  , message = "* Printing with kableExtra."
                )
                , ".print_flextable" = list(
                  output = "flextable"
                  , raw = FALSE
                  , message = "* Printing with flextable."
                )
                , ".print_screen" = list(
                  output = "screen"
                  , raw = TRUE
                  , message = "* Printing to the screen."
                )
                , ".print_excel" = list(
                  output = "excel"
                  , raw = TRUE
                  , message = glue("* Printing to Excel workbook {.astra_file_show()}.")
                )
                , ".print_excel_v1" = list(
                  output = "excel_v1"
                  , raw = FALSE
                  , message = glue("* Printing to Excel workbook {.astra_file_show()}.")
                )
                , ".print_word" = list(
                  output = "word"
                  , raw = FALSE
                  , message = glue("* Printing to Word document {.astra_file_show()}.")
                )
                , ".print_csv" = list(
                  output = "csv"
                  , raw = TRUE
                  , message = glue("* Printing to CSV file {.astra_file_show()}.")
                )
                , list(
                  output = print
                  , raw = FALSE
                  , message = glue("* Printing with a custom function: {print}")
                ))
  info$print = print
  info
}

.astra_dquote = function(x) {
  as.character(dQuote(x, q = TRUE))
}

.astra_producer = function() {
  list(
    package = "surveytable"
    , keywords = "tables, charts, estimates, R, survey, surveytable"
    , about_title = "Tables produced by the surveytable package"
    , methods = paste0("Data analyses were performed using the R package "
                       , .astra_dquote("surveytable")
                       , " (version {version}).")
    , citation_author = "Strashny A (2023). "
    , citation_title = "surveytable: Streamlining Complex Survey Estimation and Reliability Assessment in R"
    , citation_suffix = ". doi:10.32614/CRAN.package.surveytable, R package version {version}, <{url}>."
    , url = "https://cdcgov.github.io/surveytable/"
  )
}

.astra_producer_version = function(producer = .astra_producer()) {
  version = ""
  if (is.string(producer$package) && nzchar(producer$package)) {
    version = tryCatch(
      as.character(utils::packageVersion(producer$package))
      , error = function(e) ""
    )
  }
  version
}

.astra_producer_text = function(txt, producer = .astra_producer()) {
  if (is.null(txt)) {
    return(character())
  }

  txt = as.character(txt)
  txt = gsub("{version}", .astra_producer_version(producer), txt, fixed = TRUE)
  txt = gsub("{package}", producer$package, txt, fixed = TRUE)
  txt = gsub("{url}", producer$url, txt, fixed = TRUE)
  txt
}

.astra_producer_citation = function(producer = .astra_producer()) {
  paste0(
    producer$citation_author
    , producer$citation_title
    , .astra_producer_text(producer$citation_suffix, producer = producer)
  )
}

.astra_producer_citation_suffix_parts = function(producer = .astra_producer()) {
  suffix = .astra_producer_text(producer$citation_suffix, producer = producer)
  idx = regexpr(producer$url, suffix, fixed = TRUE)
  if (idx < 0) {
    return(list(before_url = suffix, after_url = ""))
  }

  idx1 = idx - 1
  idx2 = idx + nchar(producer$url)
  list(
    before_url = substr(suffix, 1, idx1)
    , after_url = substr(suffix, idx2, nchar(suffix))
  )
}

.astra_about_lines = function(markdown = FALSE) {
  producer = .astra_producer()
  title = .astra_producer_text(producer$about_title, producer = producer)
  if (markdown) {
    title = glue("**{title}**")
  }

  lines = c(
    title
    , glue("Date: {Sys.time()}")
    , ""
    , "Please include this or similar in your Methods section:"
    , .astra_producer_text(producer$methods, producer = producer)
    , .astra_producer_citation(producer = producer)
    , ""
  )
  lines[!is.na(lines)]
}

.astra_about_word = function() {
  producer = .astra_producer()
  suffix = .astra_producer_citation_suffix_parts(producer = producer)
  fp_plain = officer::fp_text_lite()
  fp_bold = officer::fp_text_lite(bold = TRUE)
  fp_italic = officer::fp_text_lite(italic = TRUE)
  fp_link = officer::fp_text_lite(underlined = TRUE, color = "blue")

  list(
    officer::fpar(officer::ftext(.astra_producer_text(producer$about_title, producer = producer), fp_bold))
    , officer::fpar(officer::ftext(glue("Date: {Sys.time()}"), fp_plain))
    , officer::fpar(officer::ftext("", fp_plain))
    , officer::fpar(officer::ftext("Please include this or similar in your Methods section:", fp_plain))
    , officer::fpar(officer::ftext(.astra_producer_text(producer$methods, producer = producer), fp_plain))
    , officer::fpar(
      officer::ftext(producer$citation_author, fp_plain)
      , officer::ftext(producer$citation_title, fp_italic)
      , officer::ftext(suffix$before_url, fp_plain)
      , officer::hyperlink_ftext(text = producer$url, href = producer$url, prop = fp_link)
      , officer::ftext(suffix$after_url, fp_plain)
    )
    , officer::fpar(officer::ftext("", fp_plain))
  )
}

.astra_about_excel = function() {
  producer = .astra_producer()
  list(
    openxlsx2::fmt_txt(.astra_producer_text(producer$about_title, producer = producer), bold = TRUE)
    , glue("Date: {Sys.time()}")
    , ""
    , "Please include this or similar in your Methods section:"
    , .astra_producer_text(producer$methods, producer = producer)
    , openxlsx2::fmt_txt(producer$citation_author) +
      openxlsx2::fmt_txt(producer$citation_title, italic = TRUE) +
      openxlsx2::fmt_txt(.astra_producer_text(producer$citation_suffix, producer = producer))
    , ""
  )
}

###
# huxtable:::assert_package
assert_package = function (fun, package, version = NULL)
{
  if (!requireNamespace(package, quietly = TRUE))
    stop(glue::glue("`{fun}` requires the \"{package}\" package. To install, type:\n",
                    "install.packages(\"{package}\")"))
  if (!is.null(version)) {
    cur_ver <- utils::packageVersion(package)
    if (cur_ver < version)
      stop(glue::glue("`{fun}` requires version {version} or higher of the \"{package}\" ",
                      "package. You have version {cur_ver} installed. To update the package,",
                      "type:\n", "install.packages(\"{package}\")"))
  }
}

