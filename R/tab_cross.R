#' @rdname tab_subset
#' @export
tab_cross = function(vr, vrby
                     , max.levels = getOption("prettysurvey.out.max_levels")
                     , screen = getOption("prettysurvey.out.screen")
                     , out = getOption("prettysurvey.out.fname")
) {
  design = .load_survey()

  newvr = paste0(vr, "x", vrby)
  mno = make.names(c(names(design$variables), newvr), unique = TRUE)
  newvr = tail(newvr,1) # Ensure unique name

  var_cross(newvr = newvr, vr = vr, vrby = vrby)

  design = .load_survey()
  ret = .tab_factor(design = design, vr = newvr
                , max.levels = max.levels
                , screen = screen
                , out = out)

  design$variables[,newvr] = NULL
  assign(getOption("prettysurvey.design"), design, envir = .GlobalEnv)
  invisible(ret)
}

#' @rdname tab_subset
#' @export
var_cross = function(newvr, vr, vrby) {
  design = .load_survey()
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

  assign(getOption("prettysurvey.design"), design, envir = .GlobalEnv)
}
