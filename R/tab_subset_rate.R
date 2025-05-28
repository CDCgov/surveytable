#' Calculate rates for subsets
#'
#' Create subsets of the survey using one variable, and tabulate
#' the rates of another variable within each of the subsets.
#'
#' @param vr      variable to tabulate
#' @param vrby    use this variable to subset the survey
#' @param pop   a `data.frame` with columns named `Level`, `Subset`, and `Population`. `Level` must
#' exactly match the levels of `vr`. `Subset` must exactly match the levels of
#' `vrby`. `Population` is the population for that level of `vr` and `vrby`.
#' @param lvls    (optional) only show these levels of `vrby`
#' @param per calculate rate per this many items in the population
#' @param drop_na drop missing values (`NA`)?
#' @param max_levels a categorical variable can have at most this many levels. Used to avoid printing huge tables.
#' @param csv     name of a CSV file
#'
#' @return A list of tables or a single table.
#' @family tables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' tab_subset_rate("AGER", "SEX", uspop2019$`AGER x SEX`)
tab_subset_rate = function(vr, vrby
                           , pop
                           , lvls = c()
                           , per = getOption("surveytable.rate_per")
                           , drop_na = getOption("surveytable.drop_na")
                           , max_levels = getOption("surveytable.max_levels")
                           , csv = getOption("surveytable.csv")
                           ) {
  design = .load_survey()
  nm = names(design$variables)
  assert_that(
    is.data.frame(pop)
    , all(names(pop) == c("Level", "Subset", "Population"))
    , nrow(pop) >= 1
    , is.numeric(pop$Population)
    , per >= 1)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(vrby %in% nm, msg = paste("Variable", vrby, "not in the data."))
  assert_that(is.factor(design$variables[,vr])
              || is.logical(design$variables[,vr])
              , msg = paste0(vr, ": must be factor or logical. Is "
                             , class(design$variables[,vr])[1] ))
  if ( !(per %in% 10^c(2:5)) ) {
    warning("Value of per is not typical: ", per)
  }

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
  if (drop_na) {
    idx = which(lvl0 == "<N/A>")
    if (length(idx) > 0) {
      lvl0 = lvl0[-idx]
    }
  }
  if (!all(lvl0 %in% pop$Subset)) {
    lvl0 %<>% intersect(pop$Subset)
    warning(glue("Population for some levels of {vrby} has not been specified."))
  }
  assert_that(all(lvl0 %in% pop$Subset)
              , msg = glue("Population for some levels of {vrby} has not been specified."))

  pop$Population = pop$Population / per
  op_ = options(surveytable.tx_count = ".tx_none"
                , surveytable.names_count = c("n", "Number", "SE_count", "LL_count", "UL_count"))
  on.exit(options(op_))

  ret = list()
  for (ii in lvl0) {
    d1 = design[which(design$variables[,vrby] == ii),]
    attr(d1$variables[,vr], "label") = paste0(
      .getvarname(design, vr), " ("
      , .getvarname(design, vrby), " = ", ii
      , ")")
    tfo = .tab_factor(design = d1
                      , vr = vr
                      , drop_na = drop_na
                      , max_levels = max_levels
                      , csv = "")
    pop1 = pop[which(pop$Subset == ii),]
    m1 = merge(tfo, pop1, by = "Level", all.x = TRUE, all.y = FALSE, sort = FALSE)
    idx = which(is.na(m1$Population))
    if (length(idx) > 0) {
      message(paste("* Population for certain levels not defined:"
                    , paste(m1$Level[idx], collapse = ", ") ))
    }
    assert_that(isTRUE(all(m1$Population > 0 | is.na(m1$Population) ))
                , msg = paste("Population values for each level of", vr, "must be positive."))
    m1[,c("Rate", "SE", "LL", "UL")] = NULL
    m1[,c("Rate", "SE", "LL", "UL")] = m1[,c("Number", "SE_count"
        , "LL_count", "UL_count")] / m1$Population
    cc = if ("Flags" %in% names(m1)) {
      c("Level", "n", "Rate", "SE", "LL", "UL", "Flags")
    } else {
      c("Level", "n", "Rate", "SE", "LL", "UL")
    }
    m1 = m1[,cc]
    cc = c("Rate", "SE", "LL", "UL")
    if (getOption("surveytable.do_tx")) {
      m1[,cc] = getOption("surveytable.tx_rate") %>% do.call(list(m1[,cc]))
    }

    attr(m1, "title") = paste(.getvarname(d1, vr), "(rate per", per, "population)")
    attr(m1, "num") = 2:6
    attr(m1, "footer") = attr(tfo, "footer")

    ret[[ii]] = .write_out(m1, csv = csv)
  }

  class(ret) = "surveytable_list"
  if (length(ret) == 1L) ret[[1]] else ret
}
