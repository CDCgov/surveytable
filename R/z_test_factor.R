.test_factor = function(design, vr, drop_na, alpha, screen, csv) {
  assert_that(alpha > 0, alpha < 0.5)
  if ( !(alpha %in% c(0.05, 0.01, 0.001)) ) {
    warning("Value of alpha is not typical: ", alpha)
  }

  lbl = .getvarname(design, vr)
  if (is.logical(design$variables[,vr])) {
    design$variables[,vr] %<>% factor
  }
  assert_that(is.factor(design$variables[,vr])
              , msg = paste0(vr, ": must be either factor or logical. Is ",
                             class(design$variables[,vr])[1] ))
  design$variables[,vr] %<>% droplevels
  if (drop_na) {
    design = design[which(!is.na(design$variables[,vr])),]
    if(inherits(design, "svyrep.design")) {
      design$prob = 1 / design$pweights
    }
    lbl %<>% paste("(knowns only)")
  } else {
    design$variables[,vr] %<>% .fix_factor
  }
  assert_that(noNA(design$variables[,vr]), noNA(levels(design$variables[,vr])))
  attr(design$variables[,vr], "label") = lbl

  nlv = nlevels(design$variables[,vr])
  if (nlv < 2) {
    warning(vr, "has less than 2 levels. Not testing.")
    return(invisible(NULL))
  }

  lvl0 = levels(design$variables[,vr])
  rT = NULL
  for (ii in 1:(nlv-1)) {
    for (jj in (ii+1):nlv) {
      lvlA = lvl0[ii]
      lvlB = lvl0[jj]
      d1 = design[which(design$variables[,vr] %in% c(lvlA, lvlB)),]
      r1 = data.frame(`Level 1` = lvlA, `Level 2` = lvlB, check.names = FALSE)
      d1$variables$tmp = 0
      d1$variables$tmp[d1$variables[,vr] == lvlB] = 1
      sgo = svyglm(tmp ~ 1, d1)
      # See survey:::svyttest.default
      r1$`p-value` = 2 * pt(-abs( (coef(sgo) - 0.5) / SE(sgo)), df = sgo$df.residual)
      rT %<>% rbind(r1)
    }
  }

  rT$Flag = ""
  idx = which(rT$`p-value` <= alpha)
  rT$Flag[idx] = "*"

  rT$`p-value` %<>% round(3)
  attr(rT, "title") = paste0("Comparison of all possible pairs of "
                             , .getvarname(design, vr) )
  attr(rT, "footer") = paste0("*: p-value <= ", alpha)
  .write_out(rT, screen = screen, csv = csv)
}
