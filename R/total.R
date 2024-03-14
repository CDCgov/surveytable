#' Total count
#'
#' @param csv     name of a CSV file
#'
#' @return A table
#' @family tables
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' total()
total = function(csv = getOption("surveytable.csv") ) {
  design = .load_survey()
  m1 = .total(design)
  attr(m1, "title") = "Total"

  .write_out(m1, csv = csv)
}

.total = function(design) {
  design$variables$Total = 1

  ##
  counts = nrow(design$variables)
  if (getOption("surveytable.find_lpe")) {
    pro = getOption("surveytable.lpe_n") %>% do.call(list(counts))
  } else {
    pro = list(flags = rep("", length(counts)), has.flag = c())
  }

  ##
  sto = svytotal(~Total, design) # , deff = "replace")
  mmcr = data.frame(x = as.numeric(sto)
              , s = sqrt(diag(attr(sto, "var"))) )
  mmcr$counts = counts
  counts_sum = sum(counts)

  mmcr$deff = deffK(design$prob)
  mmcr$samp.size = mmcr$counts / mmcr$deff
  idx.bad = which(mmcr$samp.size > mmcr$counts)
  mmcr$samp.size[idx.bad] = mmcr$counts[idx.bad]

  df1 = degf(design)
  mmcr$degf = df1

  # Equation 24 https://www.cdc.gov/nchs/data/series/sr_02/sr02-200.pdf
  # DF should be as here, not just sample size.
  mmcr$k = qt(0.975, pmax(mmcr$samp.size - 1, 0.1)) * mmcr$s / mmcr$x
  mmcr$lnx = log(mmcr$x)
  mmcr$ll = exp(mmcr$lnx - mmcr$k)
  mmcr$ul = exp(mmcr$lnx + mmcr$k)

  if (getOption("surveytable.find_lpe")) {
    pco = getOption("surveytable.lpe_counts") %>% do.call(list(mmcr))
  } else {
    pco = list(flags = rep("", nrow(mmcr)), has.flag = c())
  }

  mmc = getOption("surveytable.tx_count") %>% do.call(list(mmcr[,c("x", "s", "ll", "ul")]))
  mmc$counts = mmcr$counts
  mmc = mmc[,c("counts", "x", "s", "ll", "ul")]
  names(mmc) = getOption("surveytable.names_count")

  ##
  assert_that(nrow(mmc) == 1
              , nrow(mmcr) == 1)
  mp = mmc

  ##
  rownames(mp) = NULL

  attr(mp, "num") = 1:5
  attr(mp, "footer") = paste0("N = ", counts_sum, ".")

  if (getOption("surveytable.find_lpe")) {
    assert_that(nrow(mmc) == length(pro$flags)
      , nrow(mmc) == length(pco$flags))
    flags = paste(pro$flags, pco$flags) %>% trimws
    if (any(nzchar(flags))) {
      mp$Flags = flags
    }
    mp %<>% .add_flags( list(pro, pco) )
  }

  mp
}
