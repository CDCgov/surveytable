# if (drop_na) do that, else .fix_factor
# then, assert noNA
.fix_factor = function(xx) {
  assert_that(is.factor(xx))
  idx = which(is.na(xx))
  if (length(idx) > 0) {
    lvl = levels(xx)
    lvl_new = c(lvl, "<N/A>") %>% make.unique
    val0 = lvl_new %>% tail(1)
    xx %<>% factor(levels = lvl_new, exclude = NULL)
    xx[idx] = val0
  }

  lvl = levels(xx)
  idx = which(is.na(lvl))
  if (length(idx) > 0) {
    lvl[idx] = c(lvl, "<N/A>") %>% make.unique %>% tail(1)
    levels(xx) = lvl
  }

  assert_that(noNA(xx), noNA(levels(xx)))
  xx
}

.mymatch = function(arg, table) {
  assert_that(is.string(arg), nzchar(arg), msg = "Must be a non-empty string.")
  table %<>% tolower
  idx = arg %>% tolower %>% pmatch(table)
  xx = glue_collapse(glue('"{table}"'), sep = ", ", last = ", or ")
  assert_that(noNA(idx), msg = glue('Unknown value: "{arg}". Must be one of: {xx}.'))
  table[idx]
}

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

o2s = function(obj) {
  glue_collapse(class(obj), sep = ", ")
}

# rbind with different columns
.rbind_dc = function(df1, df2) {
  if (is.null(df1)) {
    return(df2)
  }
  at2 = setdiff( names(df1), names(df2) )
  at1 = setdiff( names(df2), names(df1) )
  if (length(at2) > 0) {
    df2[,at2] = ""
  }
  if (length(at1) > 0) {
    df1[,at1] = ""
  }
  fo = rbind(df1, df2)
  rownames(fo) = NULL
  fo
}

# show_options() |> names() |> dput()
#### !!! If making changes, update: .onLoad(), set_opts(), show_opts(), .check_options()
.check_options = function() {
  c_need = c("surveytable.drop_na", "surveytable.find_lpe",
             "surveytable.lpe_counts", "surveytable.lpe_n", "surveytable.lpe_percents",
             "surveytable.max_levels", "surveytable.names_count", "surveytable.names_count_raw",
             "surveytable.names_prct", "surveytable.print", "surveytable.file", "surveytable.file_show",
             "surveytable.p.adjust_method", "surveytable.rate_per", "surveytable.raw",
             "surveytable.survey_label", "surveytable.svychisq_statistic",
             "surveytable.svyciprop_adj", "surveytable.tx_count", "surveytable.tx_df",
             "surveytable.tx_numeric", "surveytable.tx_prct", "surveytable.tx_pval",
             "surveytable.tx_rate", "surveytable.tx_test_stat")
  c_have = show_options() %>% names()

  d_nh = setdiff(c_need, c_have)
  if (length(d_nh) > 0) {
    warning(glue("Certain package options have not been set. Try library(surveytable). "
                 , "Missing options: ", glue_collapse(d_nh, sep = ", ")))
  }

  d_hn = setdiff(c_have, c_need)
  if (length(d_hn) > 0) {
    warning(glue("Certain unnecessary options have been set. "
                 , "You could be setting an option that is no longer required "
                 , "in the current version of surveytable. "
                 , "Unnecessary options: ", glue_collapse(d_hn, sep = ", ")))
  }
}
