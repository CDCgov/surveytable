#' Tabulate subsets or interactions
#'
#' Create subsets of the survey using one variable, and tabulate another
#' variable within each of the subsets. Interact two variables and tabulate.
#' Test equality of proportions or means.
#'
#' `tab_subset` creates subsets using the levels of `vrby`, and tabulates
#' `vr` in each subset. Optionally, only use the `lvls` levels of `vrby`.
#' `vr` can be categorical (factor), logical, or numeric.
#'
#' `tab_cross` crosses or interacts `vr` and `vrby` and tabulates the new
#' variable. Tables created using `tab_subset` and `tab_cross` have the same
#' counts but different percentages. With `tab_subset`, percentages within each
#' subset add up to 100%. With `tab_cross`, percentages across the entire
#' population add up to 100%. Also see [`var_cross()`].
#'
#' @param vr      variable to tabulate
#' @param vrby    use this variable to subset the survey
#' @param lvls    (optional) only show these levels of `vrby`
#' @param test    perform hypothesis test?
#' @param alpha   significance level for the above test.
#' @param drop_na drop missing values (`NA`)? Categorical variables only.
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param screen  print to the screen?
#' @param csv     name of a CSV file
#'
#' @return
#' * `tab_subset`: A list of `data.frame` tables or a single `data.frame` table.
#' * `tab_cross`: A `data.frame` table.
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
#' # What are the levels or MAJOR?
#' tab("MAJOR")
#' # Tabulate AGER by only 2 of the levels of MAJOR
#' tab_subset("AGER", "MAJOR"
#' , lvls = c("Chronic problem, routine", "Chronic problem, flare-up"))
#'
#' # Numeric variables
#' tab_subset("NUMMED", "AGER")
#'
#' # Hypothesis testing with categorical variables
#' tab_subset("AGER", "SEX", test = TRUE)
#'
#' # Hypothesis testing with numeric variables
#' tab_subset("NUMMED", "AGER", test = TRUE)
tab_subset = function(vr, vrby, lvls = c()
                , test = FALSE, alpha = 0.05
                , drop_na = getOption("surveytable.drop_na")
                , max_levels = getOption("surveytable.max_levels")
                , screen = getOption("surveytable.screen")
                , csv = getOption("surveytable.csv")
              ) {
  assert_that(test %in% c(TRUE, FALSE)
              , alpha > 0, alpha < 0.5)
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(vrby %in% nm, msg = paste("Variable", vrby, "not in the data."))
  assert_that(is.factor(design$variables[,vr])
              || is.logical(design$variables[,vr])
              || is.numeric(design$variables[,vr])
        , msg = paste0(vr, ": must be factor, logical, or numeric. Is "
                   , class(design$variables[,vr])[1] ))

  lbl = attr(design$variables[,vrby], "label")
  if (is.logical(design$variables[,vrby])) {
    design$variables[,vrby] %<>% factor
  }
  assert_that(is.factor(design$variables[,vrby])
        , msg = paste0(vrby, ": must be either factor or logical. Is "
             , class(design$variables[,vrby])[1] ))
  design$variables[,vrby] %<>% droplevels %>% .fix_factor
  attr(design$variables[,vrby], "label") = lbl

  lvl0 = levels(design$variables[,vrby])
  if (!is.null(lvls)) {
    assert_that(all(lvls %in% lvl0))
    lvl0 = lvls
  }

  ret = list()
  if (is.logical(design$variables[,vr]) || is.factor(design$variables[,vr])) {
    for (ii in lvl0) {
      d1 = design[which(design$variables[,vrby] == ii),]
      attr(d1$variables[,vr], "label") = paste0(
        .getvarname(design, vr), " ("
        , .getvarname(design, vrby), " = ", ii
        , ")")
      ret[[ii]] = .tab_factor(design = d1
                        , vr = vr
                        , drop_na = drop_na
                        , max_levels = max_levels
                        , screen = screen
                        , csv = csv)
      if (test) {
        ret[[paste0(ii, " - test")]] = .test_factor(design = d1
                                         , vr = vr
                                         , drop_na = drop_na
                                         , alpha = alpha
                                         , screen = screen, csv = csv)
      }
    }
  } else if (is.numeric(design$variables[,vr])) {
    rA = NULL
    for (ii in lvl0) {
      d1 = design[which(design$variables[,vrby] == ii),]
      r1 = .tab_numeric_1(design = d1, vr = vr)
      rA %<>% rbind(r1)
    }
    df1 = data.frame(Level = lvl0)
    assert_that(nrow(df1) == nrow(rA))
    rA = cbind(df1, rA)
    attr(rA, "title") = paste0(.getvarname(design, vr)
         , " (for different levels of "
         , .getvarname(design, vrby), ")")
    ret[["Means"]] = .write_out(rA, screen = screen, csv = csv)

    if (test) {
      nlvl = length(lvl0)
      assert_that(nlvl >= 2L
        , msg = paste0("For ", vrby, ", at least 2 levels must be selected. "
        , "Has: ", nlvl))
      if ( !(alpha %in% c(0.05, 0.01, 0.001)) ) {
        warning("Value of alpha is not typical: ", alpha)
      }
      frm = as.formula(paste0("`", vr, "` ~ `", vrby, "`"))

      rT = NULL
      for (ii in 1:(nlvl-1)) {
        for (jj in (ii+1):nlvl) {
          lvlA = lvl0[ii]
          lvlB = lvl0[jj]
          d1 = design[which(design$variables[,vrby] %in% c(lvlA, lvlB)),]
          r1 = data.frame(`Level 1` = lvlA, `Level 2` = lvlB, check.names = FALSE)
          r1$`p-value` = svyttest(frm, d1)$p.value
          rT %<>% rbind(r1)
        }
      }

      rT$Flag = ""
      idx = which(rT$`p-value` <= alpha)
      rT$Flag[idx] = "*"

      rT$`p-value` %<>% round(3)

      attr(rT, "title") = paste0("Comparison of "
          , .getvarname(design, vr)
          , " across all possible pairs of ", .getvarname(design, vrby))
      attr(rT, "footer") = paste0("*: p-value <= ", alpha)
      ret[["p-values"]] = .write_out(rT, screen = screen, csv = csv)
    }
  } else {
    stop("How did we get here?")
  }

  if (length(ret) == 1L) return(invisible(ret[[1]]))
  invisible(ret)
}
