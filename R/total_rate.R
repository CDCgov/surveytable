#' Overall rate
#'
#' @param pop population
#' @param per calculate rate per this many items in the population
#' @param screen  print to the screen?
#' @param csv     name of a CSV file
#'
#' @return `data.frame`
#' @family tables
#' @export
#'
#' @examples
#' set_survey("vars2019")
#' total_rate(uspop2019$total)
total_rate = function(pop
    , per = getOption("surveytable.rate_per")
    , screen = getOption("surveytable.screen")
    , csv = getOption("surveytable.csv") ) {
  assert_that(pop > 0, per >= 1)
  if ( !(per %in% 10^c(2:5)) ) {
    warning("Value of per is not typical: ", per)
  }
  design = .load_survey()

  op_ = options(surveytable.tx_count = ".tx_count_none"
                , surveytable.names_count = c("Number", "SE_count"
                                              , "LL_count", "UL_count"))
  on.exit(options(op_))
  mp = .total(design)

  assert_that(nrow(mp) == 1L)
  m1 = mp
  m1$Population = pop / per
  m1[,c("Rate", "SE", "LL", "UL")] = m1[,c("Number", "SE_count"
      , "LL_count", "UL_count")] / m1$Population
  cc = if ("Flags" %in% names(m1)) {
    c("Rate", "SE", "LL", "UL", "Flags")
  } else {
    c("Rate", "SE", "LL", "UL")
  }
  m1 = m1[,cc]
  m1 = getOption("surveytable.tx_rate") %>% do.call(list(m1[, c("Rate", "SE", "LL", "UL")]))

  attr(m1, "title") = paste("Total (rate per", per, "population)")
  attr(m1, "num") = 1:4
  attr(m1, "footer") = attr(mp, "footer")

  .write_out(m1, screen = screen, csv = csv)
}
