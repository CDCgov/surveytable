#' Confidence intervals for proportions, adjusted for degrees of freedom
#'
#' A version of `survey::svyciprop()` that adjusts for the degrees of freedom
#' when `method = "beta"`.
#'
#' Written by Makram Talih in 2019.
#'
#' `df_method`: for `"default"`, `df = degf(design)`; for `"NHIS"`, `df = nrow(design) - 1`.
#'
#' To use this function in tabulations, call [set_survey()] or [set_opts()] with the
#' `mode = "NCHS"` argument, or type: `options(surveytable.adjust_svyciprop = TRUE)`.
#'
#' @param formula see `survey::svyciprop()`.
#' @param design see `survey::svyciprop()`.
#' @param method see `survey::svyciprop()`.
#' @param level see `survey::svyciprop()`.
#' @param df_method how `df` should be calculated: `"default"` or `"NHIS"`.
#' @param ... see `survey::svyciprop()`.
#'
#' @return The point estimate of the proportion, with the confidence interval as an attribute.
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' set_opts(mode = "NCHS")
#' tab("AGER")
#' set_opts(mode = "general")
svyciprop_adjusted = function(formula
                    , design
                    , method = c("logit", "likelihood", "asin", "beta"
                                 , "mean", "xlogit")
                    , level = 0.95
                    , df_method
                    , ...) {
  assert_that(df_method %in% c("default", "NHIS"))
  df = switch(df_method,
              default = degf(design),
              NHIS = nrow(design) - 1
  )

  method = match.arg(method)
  if (method != "beta") {
    return( svyciprop(formula, design, method, level, df, ...) )
  }

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
