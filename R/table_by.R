#' Tabulate subsets or interactions
#'
#' Create subsets of the survey using one variable, and tabulate another
#' variable within each of the subsets. Interact two variables and tabulate.
#'
#' `tab_subset` creates subsets using the levels of `vrby`, and tabulates
#' `vr` in each subset. Optionally, only use the `lvls` levels of `vrby`.
#'
#' `tab_cross` crosses or interacts `vr` and `vrby` and tabulates the new
#' variable. Tables created using `tab_subset` and `tab_cross` have the same
#' counts but different percentages. With `tab_subset`, percentages within each
#' subset add up to 100%. With `tab_cross`, percentages across the entire survey
#' add up to 100%.
#'
#' `var_cross` creates the new variable, returns the updates survey,
#' but does not tabulate the new variable. Use [`tab()`] to tabulate it.
#'
#' @param design  survey design
#' @param vr      variable to tabulate
#' @param vrby    use this variable to subset the survey
#' @param lvls    (optional) only show these levels of `vrby`
#' @param max.levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param screen  print to the screen?
#' @param out     file name of CSV file
#' @param newvr   name of the new variable to be created
#'
#' @return
#' * `tab_subset`: a list of `data.frame` tables.
#' * `tab_cross`: a `data.frame` table.
#' * `var_cross`: an updated `survey.design`.
#'
#' @family tables
#'
#' @export
#'
#' @examples
#' # For each SEX, tabulate AGER
#' tab_subset(namcs2019, "AGER", "SEX")
#'
#' # Same counts as tab_subset(), but different percentages.
#' tab_cross(namcs2019, "AGER", "SEX")
#'
#' # Same thing, but creates and retains the new variable:
#' namcs2019 = var_cross(namcs2019, "Age x Sex", "AGER", "SEX")
#' tab(namcs2019, "Age x Sex")
#'
#' # What are the levels or MAJOR?
#' tab(namcs2019, "MAJOR")
#' # Tabulate AGER by only 2 of the levels of MAJOR
#' tab_subset(namcs2019, "AGER", "MAJOR"
#' , lvls = c("Chronic problem, routine", "Chronic problem, flare-up"))
tab_subset = function(design, vr, vrby
                      , lvls = c()
               , max.levels = getOption("prettysurvey.out.max_levels")
               , screen = getOption("prettysurvey.out.screen")
               , out = getOption("prettysurvey.out.fname")
              ) {
  lbl = attr(design$variables[,vrby], "label")
  if (is.logical(design$variables[,vrby])) {
    design$variables[,vrby] = as.factor(design$variables[,vrby])
  }
  assert_that(is.factor(design$variables[,vrby])
              , msg = paste0(vrby, ": must be either factor or logical. Is ",
                             class(design$variables[,vrby]) ))
  design$variables[,vrby] %<>% droplevels
  attr(design$variables[,vrby], "label") = lbl

  lvl0 = levels(design$variables[,vrby])
  if (!is.null(lvls)) {
    assert_that(all(lvls %in% lvl0))
    lvl0 = lvls
  }

  ret = list()
  for (ii in lvl0) {
    d1 = design[which(design$variables[,vrby] == ii),]
    txtby = paste(.getvarname(design, vrby), "=", ii)
    attr(d1$variables[,vr], "label") = paste0(
      .getvarname(design, vr), " (", txtby, ")")
    ret[[ii]] = .tab_factor(design = d1
                               , vr = vr
                               , max.levels = max.levels
                               , screen = screen
                               , out = out
                            )
  }
  invisible(ret)
}


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
  assert_that(!(newvr %in% nm), msg = paste("Variable", newvr, "already exists."))
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(vrby %in% nm, msg = paste("Variable", vrby, "not in the data."))

  design$variables[,newvr] = forcats::fct_cross(
    design$variables[,vr]
    , design$variables[,vrby])
  attr(design$variables[,newvr], "label") = paste0(
    "(", .getvarname(design, vr), ") x ("
    , .getvarname(design, vrby), ")")

  design
}
