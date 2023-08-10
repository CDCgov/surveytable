#' @rdname tab_subset
#' @export
tab_cross = function(vr, vrby
                     , max_levels = getOption("surveytable.max_levels")
                     , screen = getOption("surveytable.screen")
                     , csv = getOption("surveytable.csv")
) {
  design = .load_survey()

  # Ensure unique name
  newvr = paste0(vr, "x", vrby)
  newvr = make.names(c(names(design$variables), newvr), unique = TRUE) %>% tail(1)

  var_cross(newvr = newvr, vr = vr, vrby = vrby)

  design = .load_survey()
  ret = .tab_factor(design = design, vr = newvr
                , max_levels = max_levels
                , screen = screen
                , csv = csv)

  design$variables[,newvr] = NULL
  assign(getOption("surveytable.survey"), design, envir = .GlobalEnv)
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

  x1 = design$variables[,vr]
  x2 = design$variables[,vrby]
  if (is.logical(x1)) {
    x1 %<>% factor
  }
  if (is.logical(x2)) {
    x2 %<>% factor
  }
  assert_that(is.factor(x1)
      , msg = paste0(vr, ": must be either factor or logical. Is ",
                     class(design$variables[,vr])[1] ))
  assert_that(is.factor(x2)
      , msg = paste0(vrby, ": must be either factor or logical. Is ",
                     class(design$variables[,vrby])[1] ))
  x1 %<>% .fix_factor
  x2 %<>% .fix_factor
  design$variables[,newvr] = forcats::fct_cross(x1, x2, sep = " : ", keep_empty = TRUE)
  attr(design$variables[,newvr], "label") = paste0(
    "(", .getvarname(design, vr), ") x ("
    , .getvarname(design, vrby), ")")

  assign(getOption("surveytable.survey"), design, envir = .GlobalEnv)
}
