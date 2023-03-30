.tab_numeric = function(design, vr, screen, csv) {
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(is.numeric(design$variables[,vr])
    , msg = paste0(vr, ": must be either numeric. Is ",
                   class(design$variables[,vr]) ))

  ret = data.frame(k
     = 100 * sum(!is.na(design$variables[,vr])) / nrow(design$variables))
  names(ret) = "% known"

  frm = as.formula(paste0("~ `", vr, "`"))
  smo = svymean(frm, design, na.rm = TRUE)
  ret$Mean = smo %>% as.numeric
  ret$SEM = smo %>% attr("var") %>% sqrt %>% as.numeric
  ret$SD = svyvar(frm, design, na.rm = TRUE) %>% as.numeric %>% sqrt

  #
  attr(ret, "title") = .getvarname(design, vr)
  .write_out(ret, screen = screen, csv = csv)
}