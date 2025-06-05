#' Korn and Graubard confidence intervals for proportions, adjusted for degrees of freedom
#'
#' A version of `survey::svyciprop( method = "beta" )` that adjusts for the degrees of freedom.
#'
#' `adj` specifies the adjustment to the Korn and Graubard confidence intervals.
#'
#' * `"none"`: No adjustment is performed. Produces standard Korn and Graubard confidence intervals,
#' same as `survey::svyciprop( method = "beta" )`.
#'
#' * `"NCHS"`: Adjustment that might be required by some (though not all) NCHS data systems. With
#' this adjustment, the degrees of freedom is set to `degf(design)`. Consult the documentation
#' for the data system that you are analyzing to determine if this is the appropriate
#' adjustment.
#'
#' * `"NHIS"`: Adjustment that might be required by NHIS. With this adjustment, the degrees
#' of freedom is set to `nrow(design) - 1`. Consult the documentation
#' for the data system that you are analyzing to determine if this is the appropriate
#' adjustment.
#'
#' To use these adjustments in `surveytable` tabulations, call [set_survey()] or [set_opts()] with the
#' appropriate `mode` or `adj` argument.
#'
#' Originally written by Makram Talih in 2019.
#'
#' @param formula see `survey::svyciprop()`.
#' @param design see `survey::svyciprop()`.
#' @param level see `survey::svyciprop()`.
#' @param adj adjustment to the Korn and Graubard confidence intervals: `"none"` (default),
#' `"NCHS"`, or `"NHIS"`.
#' @param ... see `survey::svyciprop()`.
#'
#' @return The point estimate of the proportion, with the confidence interval as an attribute.
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' set_opts(adj = "NCHS")
#' tab("AGER")
#' set_opts(adj = "none")
svyciprop_adjusted = function(formula
                    , design
                    , level = 0.95
                    , adj = "none"
                    , ...) {
  adj %<>% .mymatch(c("none", "nchs", "nhis"))
  if ( !(level %in% c(0.95, 0.9, 0.99)) ) {
    warning("Value of level is not typical: ", level)
  }

  if (adj == "none") {
    return(
      svyciprop(formula = formula, design = design, method = "beta"
                , level = level, ...)
    )
  }

  df = switch(adj,
              nchs = degf(design),
              nhis = nrow(design) - 1
              , stop("??")
  )

  m = eval(bquote(svymean(~as.numeric(.(formula[[2]])), design, ...)))
  rval = coef(m)[1]

  #Effective sample size
  n.eff = coef(m) * (1 - coef(m))/stats::vcov(m)

  attr(rval, "var") = stats::vcov(m)
  alpha = 1 - level

  # Degrees of freedom used only for adjusting effective sample size, below

  # For NHIS, provisional guideline is to override the R default
  # df = nrow(design) - 1  ## uncomment this row to override R default

  # R-default from degf(design) uses subdomain Strata and PSUs

  if (df >0) {     #Korn-Graubard df-adjustment factor
    rat.squ = (qt(alpha/2, nrow(design) - 1)/qt(alpha/2, df))^2
  } else {
    rat.squ = 0 # limit case: set to zero
  }

  if (rval > 0) {  #Adjusted effective sample size
    n.eff = min(nrow(design), n.eff*rat.squ)
  } else {
    n.eff = nrow(design) #limit case: set to sample size
  }

  ci = c(stats::qbeta(alpha/2, n.eff*rval, n.eff*(1-rval)+1), stats::qbeta(1-alpha/2, n.eff*rval+1, n.eff*(1 - rval)))

  halfalpha = (1 - level)/2
  names(ci) = paste(round(c(halfalpha, (1 - halfalpha))*100, 1), "%", sep = "")
  names(rval) = deparse(formula[[2]])
  attr(rval, "ci") = ci
  class(rval) = "svyciprop"
  rval
}
