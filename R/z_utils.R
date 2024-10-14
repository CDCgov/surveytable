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
