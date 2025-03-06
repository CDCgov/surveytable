#' Calculate rates
#'
#' Calculate the rates for categorical (factor) or logical variables.
#'
#' @param vr variable to tabulate
#' @param pop   either a single number or a `data.frame` with columns named
#' `Level` and `Population`. `Level` must
#' exactly match the levels of `vr`. `Population` is the population for that
#' level of `vr`.
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
#' # pop is a data frame
#' tab_rate("MSA", uspop2019$MSA)
#'
#' # pop is a single number
#' tab_rate("MDDO", uspop2019$total)
tab_rate = function(vr, pop
  , per = getOption("surveytable.rate_per")
  , drop_na = getOption("surveytable.drop_na")
  , max_levels = getOption("surveytable.max_levels")
  , csv = getOption("surveytable.csv")
  ) {

  assert_that(is.data.frame(pop) || is.number(pop)
    , msg = paste0("pop must be either a data frame or a number. Is ", class(pop)[1]))
  pop_df = is.data.frame(pop)
  if (pop_df) {
    assert_that( all(names(pop) == c("Level", "Population"))
      , nrow(pop) >= 1
      , is.numeric(pop$Population) )
  } else {
    assert_that(pop > 0)
  }

  assert_that(per >= 1)
  if ( !(per %in% 10^c(2:5)) ) {
    warning("Value of per is not typical: ", per)
  }

  design = .load_survey()
  nm = names(design$variables)
  assert_that(vr %in% nm, msg = paste("Variable", vr, "not in the data."))
  assert_that(is.factor(design$variables[,vr])
              || is.logical(design$variables[,vr])
                , msg = paste0(vr, ": must be factor or logical. Is "
                             , class(design$variables[,vr])[1] ))

  op_ = options(surveytable.tx_count = ".tx_none"
                  , surveytable.names_count = c("n", "Number", "SE_count"
                    , "LL_count", "UL_count"))
  on.exit(options(op_))
  tfo = .tab_factor(design = design
            , vr = vr
            , drop_na = drop_na
            , max_levels = max_levels
            , csv = "")

  if (pop_df) {
    pop$Population = pop$Population / per
    m1 = merge(tfo, pop, by = "Level", all.x = TRUE, all.y = FALSE, sort = FALSE)
  } else {
    m1 = tfo
    m1$Population = pop / per
    message("* Rate based on the entire population.")
  }
  idx = which(is.na(m1$Population))
  if (length(idx) > 0) {
    message(paste("* Population for some levels not defined:"
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
  m1[,cc] = getOption("surveytable.tx_rate") %>% do.call(list(m1[,cc]))

  attr(m1, "title") = paste(.getvarname(design, vr), "(rate per", per, "population)")
  attr(m1, "num") = 2:6
  attr(m1, "footer") = attr(tfo, "footer")

  .write_out(m1, csv = csv)
}
