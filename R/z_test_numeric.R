.test_numeric = function(design, vr, vrby, lvl0, alpha, p_adjust, csv, test_title) {
  assert_that(alpha > 0, alpha < 0.5
              , p_adjust %in% c(TRUE, FALSE))
  if ( !(alpha %in% c(0.05, 0.01, 0.001)) ) {
    warning("Value of alpha is not typical: ", alpha)
  }

  nlvl = length(lvl0)
  assert_that(nlvl >= 2L
              , msg = glue("For {vrby}, at least 2 levels must be selected. "
                             , "Has: {nlvl}"))

  frm = as.formula(paste0("`", vr, "` ~ `", vrby, "`"))

  rT = NULL
  for (ii in 1:(nlvl-1)) {
    for (jj in (ii+1):nlvl) {
      lvlA = lvl0[ii]
      lvlB = lvl0[jj]
      d1 = design[which(design$variables[,vrby] %in% c(lvlA, lvlB)),]
      r1 = data.frame(`Level 1` = lvlA, `Level 2` = lvlB, check.names = FALSE)
      xx = svyttest(frm, d1)
      r1$`Test statistic` = xx$statistic
      r1$`Degrees of freedom` = xx$parameter
      r1$`p-value` = xx$p.value
      rT %<>% rbind(r1)
    }
  }
  test_name = xx$method
  if (p_adjust) {
    method = getOption("surveytable.p.adjust_method", default = "bonferroni")
    rT$`p-adjusted` = p.adjust(rT$`p-value`
                               , method = method)
    test_name %<>% paste0("; ", method, " adjustment")
  }

  .test_table(rT = rT
              , test_name = test_name, test_title = test_title
              , alpha = alpha, csv = csv)
}
