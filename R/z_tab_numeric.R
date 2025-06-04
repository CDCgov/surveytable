.tab_numeric = function(design, vr, csv) {
  ret = .tab_numeric_1(design, vr)
  attr(ret, "title") = .getvarname(design, vr)
  .write_out(ret, csv = csv)
}

.tab_numeric_1 = function(design, vr) {
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(is.numeric(design$variables[,vr])
            , msg = paste0(vr, ": must be numeric. Is "
             , class(design$variables[,vr])[1] ))

  # convert to 0-100 scale below
  ret = data.frame(k = sum(!is.na(design$variables[,vr])) / nrow(design$variables))
  names(ret) = "% known"

  frm = as.formula(paste0("~ `", vr, "`"))
  smo = svymean(frm, design, na.rm = TRUE)
  ret$Mean = smo %>% as.numeric
  ret$SEM = smo %>% attr("var") %>% sqrt %>% as.numeric

  # Warning messages:
  #   1: In thetas - meantheta :
  #   Recycling array of length 1 in vector-array arithmetic is deprecated.
  # Use c() or as.vector() instead.
  ret$SD = (svyvar(frm, design, na.rm = TRUE)
            %>% as.numeric %>% sqrt %>% suppressWarnings)

  if (getOption("surveytable.not_raw")) {
    cc = c("Mean", "SEM", "SD")
    ret[,cc] = getOption("surveytable.tx_numeric") %>% do.call(list(ret[,cc]))
    cc = "% known"
    ret[,cc] = getOption("surveytable.tx_prct") %>% do.call(list(ret[,cc]))
  }

  ret
}
