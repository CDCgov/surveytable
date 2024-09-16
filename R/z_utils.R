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
  assert_that(is.string(arg), nzchar(arg))
  table %<>% tolower
  idx = arg %>% tolower %>% pmatch(table)
  assert_that(noNA(idx), msg = paste("Unknown value:", arg))
  table[idx]
}
