#' @rdname tab_subset
#' @export
tab_cross = function(design, vr, vrby
                     , max.levels = getOption("prettysurvey.out.max_levels")
                     , screen = getOption("prettysurvey.out.screen")
                     , out = getOption("prettysurvey.out.fname")
) {
  newvr = paste0(vr, "x", vrby)
  design %>% var_cross(newvr = newvr, vr = vr, vrby = vrby) %>% .tab_factor(vr = newvr
                                                                            , max.levels = max.levels
                                                                            , screen = screen
                                                                            , out = out)

}

#' @rdname tab_subset
#' @export
var_cross = function(design, newvr, vr, vrby) {
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(vrby %in% nm, msg = paste("Variable", vrby, "not in the data."))
  if(newvr %in% nm) {
    warning(newvr, ": overwriting a variable that already exists.")
  }

  design$variables[,newvr] = forcats::fct_cross(
    design$variables[,vr]
    , design$variables[,vrby])
  attr(design$variables[,newvr], "label") = paste0(
    "(", .getvarname(design, vr), ") x ("
    , .getvarname(design, vrby), ")")

  design
}
