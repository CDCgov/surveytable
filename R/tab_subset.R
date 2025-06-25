#' Tabulate subsets or interactions
#'
#' Create subsets of the survey using one variable, and tabulate another
#' variable within each of the subsets. Interact two variables and tabulate.
#'
#' `tab_subset()` creates subsets using the levels of `vrby`, and tabulates
#' `vr` in each subset. Optionally, only use the `lvls` levels of `vrby`.
#' `vr` can be categorical (factor or character), logical, or numeric.
#'
#' `tab_cross()` crosses or interacts `vr` and `vrby` and tabulates the new
#' variable. Tables created using `tab_subset()` and `tab_cross()` have the same
#' counts but different percentages. With `tab_subset()`, percentages within each
#' subset add up to 100%. With `tab_cross()`, percentages across the entire
#' population add up to 100%. Also see `var_cross()`.
#'
#' `test = TRUE` performs a test of association between the two variables. Also
#' performs t-tests for all pairs of levels of `vr` and `vrby`.
#'
#' `test = "{LEVEL}"`, where `{LEVEL}` is a level of `vr`, performs a
#' **conditional independence test** to compare the proportion of
#' `vr = "{LEVEL}"` for different values of `vrby`.
#'
#' @param vr      variable to tabulate
#' @param vrby    use this variable to subset the survey
#' @param lvls    (optional) only show these levels of `vrby`
#' @param test    if `TRUE`, performs a test of association and t-tests for all
#' pairs of levels of `vr` and `vrby`. If `test` is the name of a level of `vr`,
#' performs a conditional independence test for that level.
#' @param alpha   significance level for tests
#' @param p_adjust adjust p-values for multiple comparisons?
#' @param drop_na drop missing values (`NA`)? Categorical variables only.
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param csv     name of a CSV file
#'
#' @return A list of tables or a single table.
#'
#' @family tables
#'
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#'
#' # For each SEX, tabulate AGER
#' tab_subset("AGER", "SEX")
#'
#' # Same counts as tab_subset(), but different percentages.
#' tab_cross("AGER", "SEX")
#'
#' # Numeric variables
#' tab_subset("NUMMED", "AGER")
#'
#' # Hypothesis testing
#' tab_subset("NUMMED", "AGER", test = TRUE)
tab_subset = function(vr, vrby, lvls = c()
                , test = FALSE, alpha = 0.05, p_adjust = FALSE
                # , test_pairs = "depends"
                , drop_na = getOption("surveytable.drop_na")
                , max_levels = getOption("surveytable.max_levels")
                , csv = getOption("surveytable.csv")
              ) {
  assert_that(alpha > 0, alpha < 0.5
              , p_adjust %in% c(TRUE, FALSE)
              )
  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(vrby %in% nm, msg = paste("Variable", vrby, "not in the data."))
  assert_that(is.factor(design$variables[,vr])
              || is.logical(design$variables[,vr])
              || is.numeric(design$variables[,vr])
        , msg = paste0(vr, ": must be factor, logical, or numeric. Is "
                   , class(design$variables[,vr])[1] ))

  # Need to convert to factor for testing
  if (is.logical(design$variables[,vr])) {
    lbl = attr(design$variables[,vr], "label")
    design$variables[,vr] %<>% factor %>% droplevels

    if (drop_na) {
      design = design[which(!is.na(design$variables[,vr])),]
      if(inherits(design, "svyrep.design")) {
        design$prob = 1 / design$pweights
      }
      # drop_na in .tab_factor will set this
      # lbl %<>% paste("(knowns only)")
    } else {
      design$variables[,vr] %<>% .fix_factor
    }
    assert_that(noNA(design$variables[,vr]), noNA(levels(design$variables[,vr])))

    attr(design$variables[,vr], "label") = lbl
  }
  assert_that(test %in% c(TRUE, FALSE) | test %in% levels(design$variables[,vr]))
  type_test = if (test %in% levels(design$variables[,vr])) {
    "cit"
  } else if (test == TRUE) {
    "assoc"
  } else if (test == FALSE) {
    "none"
  }


  lbl = attr(design$variables[,vrby], "label")
  if (is.logical(design$variables[,vrby])) {
    design$variables[,vrby] %<>% factor
  }
  assert_that(is.factor(design$variables[,vrby])
        , msg = glue("{vrby}: must be either categorical (factor or character) or logical.",
                     " Is {o2s(design$variables[,vrby])}"))
  design$variables[,vrby] %<>% droplevels %>% .fix_factor
  attr(design$variables[,vrby], "label") = lbl

  lvl0 = levels(design$variables[,vrby])
  if (!is.null(lvls)) {
    assert_that(all(lvls %in% lvl0))
    lvl0 = lvls
  }
  if (drop_na) {
    idx = which(lvl0 == "<N/A>")
    if (length(idx) > 0) {
      lvl0 = lvl0[-idx]
    }
  }

  ret = list()
  if (is.factor(design$variables[,vr]) && type_test == "cit") {
    r1 = NULL
    l.num = list()
    c.footer = c()
    for (ii in lvl0) {
      d1 = design[which(design$variables[,vrby] == ii),]
      if(inherits(d1, "svyrep.design")) {
        d1$prob = 1 / d1$pweights
      }
      fo = .tab_factor(design = d1
                  , vr = vr
                  , drop_na = drop_na
                  , max_levels = max_levels
                  , csv = csv)
      l.num[[ length(l.num) + 1 ]] = attr(fo, "num")
      c.footer %<>% c(attr(fo, "footer"))

      idx = which(fo$Level == test)
      assert_that(length(idx) == 1)
      fo1 = fo[idx,]
      fo1$Level = ii
      r1 %<>% .rbind_dc(fo1)
    }
    attr(r1, "title") = glue("{.getvarname(design, vr)} = '{test}' "
                             , "(for different levels of {.getvarname(design, vrby)})")
    for (kk in 1:length(l.num)) assert_that(all(l.num[[kk]] == l.num[[1]]))
    attr(r1, "num") = l.num[[1]]
    ## What to do with footer?
    attr(r1, "footer") = ""
    ret[[ "table - conditional independence" ]] = r1

    # Test
    design$variables$.tmp = as.numeric(design$variables[,vr] == test)
    ret[[ "test - conditional independence" ]] = .test_numeric(
      design = design, vr = ".tmp", vrby = vrby, lvl0 = lvl0, alpha = alpha
      , p_adjust = p_adjust, csv = csv
      , test_title = glue("Conditional independence test of {.getvarname(design, vr)} = '{test}' "
                          , "across all pairs of {.getvarname(design, vrby)}")
    )
  } else if (is.factor(design$variables[,vr]) && type_test != "cit") {
    for (ii in lvl0) {
      d1 = design[which(design$variables[,vrby] == ii),]
      if(inherits(d1, "svyrep.design")) {
        d1$prob = 1 / d1$pweights
      }

      attr(d1$variables[,vr], "label") = paste0(
        .getvarname(design, vr), " ("
        , .getvarname(design, vrby), " = ", ii
        , ")")
      ret[[ii]] = .tab_factor(design = d1
                        , vr = vr
                        , drop_na = drop_na
                        , max_levels = max_levels
                        , csv = csv)
    }

    if (type_test == "assoc") {
      frm = as.formula(paste0("~ `", vr, "` + `", vrby, "`"))
      fo = svychisq(frm, design
        , statistic = getOption("surveytable.svychisq_statistic", default = "F"))
      rT = data.frame(`Test statistic` = fo$statistic
        , `Degrees of freedom 1` = fo$parameter[1]
        , `Degrees of freedom 2` = fo$parameter[2]
        , `p-value` = fo$p.value
        , check.names = FALSE)
      test_name = fo$method
      test_title = paste0("Association between "
                          , .getvarname(design, vr)
                          , " and ", .getvarname(design, vrby))
      # do_pairs = if(test_pairs == "no") {
      #   FALSE
      # } else if(test_pairs == "yes") {
      #   TRUE
      # } else {
      #   rT$`p-value` <= alpha
      # }

      ret[[ test_name ]] = .test_table(rT = rT
             , test_name = test_name, test_title = test_title, alpha = alpha
             , csv = csv)

      ###
      for (ii in lvl0 ) {
        d1 = design[which(design$variables[,vrby] == ii),]
        if(inherits(d1, "svyrep.design")) {
          d1$prob = 1 / d1$pweights
        }

        attr(d1$variables[,vr], "label") = paste0(
          .getvarname(design, vr), " ("
          , .getvarname(design, vrby), " = ", ii
          , ")")
        ret[[paste0(ii, " - test")]] = .test_factor(design = d1
                                                    , vr = vr
                                                    , drop_na = drop_na
                                                    , alpha = alpha
                                                    , p_adjust = p_adjust
                                                    , csv = csv)
      }

      for (jj in levels(design$variables[,vr]) ) {
        d1 = design[which(design$variables[,vr] == jj),]
        if(inherits(d1, "svyrep.design")) {
          d1$prob = 1 / d1$pweights
        }

        attr(d1$variables[,vrby], "label") = paste0(
          .getvarname(design, vrby), " ("
          , .getvarname(design, vr), " = ", jj
          , ")")
        ret[[paste0(jj, " - test")]] = .test_factor(design = d1
                                                    , vr = vrby
                                                    , drop_na = drop_na
                                                    , alpha = alpha
                                                    , p_adjust = p_adjust
                                                    , csv = csv)
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
    ret[["Means"]] = .write_out(rA, csv = csv)

    if (test) {
      frm = as.formula(paste0("`", vr, "` ~ `", vrby, "`"))
      model1 = svyglm(frm, design)
      fo = regTermTest(model1, vrby, method = "Wald")
      rT = data.frame(`Test statistic` = fo$Ftest
        , `Degrees of freedom 1` = fo$df
        , `Degrees of freedom 2` = fo$ddf
        , `p-value` = fo$p, check.names = FALSE)
      # survey:::print.regTermTest
      test_name = "Wald test"
      test_title = paste0("Association between "
                          , .getvarname(design, vr)
                          , " and ", .getvarname(design, vrby))

      # do_pairs = if(test_pairs == "no") {
      #   FALSE
      # } else if(test_pairs == "yes") {
      #   TRUE
      # } else {
      #   rT$`p-value` <= alpha
      # }

      ret[[ test_name ]] = .test_table(rT = rT
             , test_name = test_name, test_title = test_title, alpha = alpha
             , csv = csv)
    # }
    # if (test && do_pairs) {
      ret[[ "t-test" ]] = .test_numeric(
        design = design, vr = vr, vrby = vrby, lvl0 = lvl0, alpha = alpha
        , p_adjust = p_adjust, csv = csv
        , test_title = glue("Comparison of {.getvarname(design, vr)} across all possible "
                            , "pairs of {.getvarname(design, vrby)}")
      )
    }
  } else {
    stop("How did we get here?")
  }

  class(ret) = "surveytable_list"
  if (length(ret) == 1L) ret[[1]] else ret
}
