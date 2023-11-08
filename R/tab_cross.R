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
                    , drop_na = FALSE
                , max_levels = max_levels
                , screen = screen
                , csv = csv)

  design$variables[,newvr] = NULL
  assign(getOption("surveytable.survey"), design, envir = .GlobalEnv)
  invisible(ret)
}
