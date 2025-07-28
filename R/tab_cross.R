#' @rdname tab_subset
#' @export
tab_cross = function(vr, vrby, max_levels = getOption("surveytable.max_levels")
                     ) {
  design = .load_survey()

  # Ensure unique name
  newvr = paste0(vr, "x", vrby)
  newvr = make.names(c(names(design$variables), newvr), unique = TRUE) %>% tail(1)

  var_cross(newvr = newvr, vr = vr, vrby = vrby)

  design = .load_survey()
  attr(design$variables[,newvr], "label") = paste0(
    "(", .getvarname(design, vr), ") x ("
    , .getvarname(design, vrby), ")")
  ret = .tab_factor(design = design, vr = newvr
                    , drop_na = FALSE
                    , max_levels = max_levels)

  design$variables[,newvr] = NULL
  env$survey = design
  ret
}
