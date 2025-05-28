#' Overall rate
#'
#' @param pop population
#' @param per calculate rate per this many items in the population
#' @param csv     name of a CSV file
#'
#' @return A table
#' @family tables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' total_rate(uspop2019$total)
total_rate = function(pop
    , per = getOption("surveytable.rate_per")
    , csv = getOption("surveytable.csv") ) {
  assert_that(pop > 0, per >= 1)
  if ( !(per %in% 10^c(2:5)) ) {
    warning("Value of per is not typical: ", per)
  }
  design = .load_survey()

  op_ = options(surveytable.tx_count = ".tx_none"
                , surveytable.names_count = c("n", "Number", "SE_count"
                                              , "LL_count", "UL_count"))
  on.exit(options(op_))
  mp = .total(design)

  assert_that(nrow(mp) == 1L)
  m1 = mp
  m1$Population = pop / per
  m1[,c("Rate", "SE", "LL", "UL")] = NULL
  m1[,c("Rate", "SE", "LL", "UL")] = m1[,c("Number", "SE_count"
      , "LL_count", "UL_count")] / m1$Population
  cc = if ("Flags" %in% names(m1)) {
    c("n", "Rate", "SE", "LL", "UL", "Flags")
  } else {
    c("n", "Rate", "SE", "LL", "UL")
  }
  m1 = m1[,cc]
  cc = c("Rate", "SE", "LL", "UL")
  if (getOption("surveytable.do_tx")) {
    m1[,cc] = getOption("surveytable.tx_rate") %>% do.call(list(m1[,cc]))
  }

  attr(m1, "title") = paste("Total (rate per", per, "population)")
  attr(m1, "num") = 1:5
  attr(m1, "footer") = attr(mp, "footer")

  .write_out(m1, csv = csv)
}
