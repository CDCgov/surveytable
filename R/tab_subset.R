#' Tabulate subsets or interactions
#'
#' Create subsets of the survey using one variable, and tabulate another
#' variable within each of the subsets. Interact two variables and tabulate.
#'
#' `tab_subset` creates subsets using the levels of `vrby`, and tabulates
#' `vr` in each subset. Optionally, only use the `lvls` levels of `vrby`.
#' Works with numeric variables as well.
#'
#' `tab_cross` crosses or interacts `vr` and `vrby` and tabulates the new
#' variable. Tables created using `tab_subset` and `tab_cross` have the same
#' counts but different percentages. With `tab_subset`, percentages within each
#' subset add up to 100%. With `tab_cross`, percentages across the entire
#' population add up to 100%.
#'
#' `var_cross` creates the new variable and updates the survey,
#' but does not tabulate the new variable. Use [`tab()`] to tabulate it.
#'
#' @param vr      variable to tabulate
#' @param vrby    use this variable to subset the survey
#' @param lvls    (optional) only show these levels of `vrby`
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param screen  print to the screen?
#' @param csv     name of a CSV file
#' @param newvr   name of the new variable to be created
#'
#' @return
#' * `tab_subset`: A list of `data.frame` tables or a single `data.frame` table.
#' * `tab_cross`: A `data.frame` table.
#' * `var_cross`: (Nothing.)
#'
#' @family tables
#'
#' @export
#'
#' @examples
#' set_survey("vars2019")
#'
#' # For each SEX, tabulate AGER
#' tab_subset("AGER", "SEX")
#'
#' # Same counts as tab_subset(), but different percentages.
#' tab_cross("AGER", "SEX")
#'
#' # Same thing, but creates and retains the new variable:
#' var_cross("Age x Sex", "AGER", "SEX")
#' tab("Age x Sex")
#'
#' # What are the levels or MAJOR?
#' tab("MAJOR")
#' # Tabulate AGER by only 2 of the levels of MAJOR
#' tab_subset("AGER", "MAJOR"
#' , lvls = c("Chronic problem, routine", "Chronic problem, flare-up"))
#'
#' # Numeric variables
#' tab_subset("BMI.nospecial", "AGER")
tab_subset = function(vr, vrby, lvls = c()
               , max_levels = getOption("prettysurvey.max_levels")
               , screen = getOption("prettysurvey.screen")
               , csv = getOption("prettysurvey.csv")
              ) {
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(vrby %in% nm, msg = paste("Variable", vrby, "not in the data."))
  assert_that(is.factor(design$variables[,vr])
              || is.logical(design$variables[,vr])
              || is.numeric(design$variables[,vr])
              , msg = paste0(vr, ": must be factor, logical, or numeric. Is ",
                             class(design$variables[,vr]) ))

  lbl = attr(design$variables[,vrby], "label")
  if (is.logical(design$variables[,vrby])) {
    design$variables[,vrby] %<>% factor
  }
  assert_that(is.factor(design$variables[,vrby])
              , msg = paste0(vrby, ": must be either factor or logical. Is ",
                             class(design$variables[,vrby]) ))
  design$variables[,vrby] %<>% droplevels %>% .fix_factor
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
    if (is.logical(design$variables[,vr])
        || is.factor(design$variables[,vr])) {
      ret[[ii]] = .tab_factor(design = d1
                   , vr = vr
                   , max_levels = max_levels
                   , screen = screen
                   , csv = csv)
    } else if (is.numeric(design$variables[,vr])) {
      ret[[ii]] = .tab_numeric(design = d1
                     , vr = vr
                     , screen = screen
                     , csv = csv)
    }
  }

  if (length(ret) == 1L) return(invisible(ret[[1]]))
  invisible(ret)
}
