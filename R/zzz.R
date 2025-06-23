env = new.env()

.onLoad = function(libname, pkgname) {
  options(
    surveytable.survey_label = ""

    ## set_opts(mode = "general")
    , surveytable.tx_count = ".tx_count_int"
    , surveytable.names_count = c("n", "Number", "SE", "LL", "UL")
    , surveytable.names_count_raw = c("n", "Number", "SE", "LL", "UL")
    , surveytable.find_lpe = FALSE
    , surveytable.svyciprop_adj = "none"

    ## related
    , surveytable.lpe_n = ".lpe_n"
    , surveytable.lpe_counts = ".lpe_counts"
    , surveytable.lpe_percents = ".lpe_percents"

    ## other set_opts()
    , surveytable.raw = FALSE
    , surveytable.drop_na = FALSE
    , surveytable.max_levels = 20
    , surveytable.csv = ""
    , surveytable.output_object = ".as_object_auto"
    , surveytable.output_print = ".print_auto"

    ## other
    , surveytable.tx_prct = ".tx_prct"
    , surveytable.names_prct = c("Percent", "SE", "LL", "UL")

    , surveytable.rate_per = 100
    , surveytable.tx_rate = ".tx_rate"

    , surveytable.tx_numeric = ".tx_numeric"

    , surveytable.svychisq_statistic = "F"
    , surveytable.p.adjust_method = "bonferroni"
    , surveytable.tx_pval = ".tx_pval"
    , surveytable.tx_test_stat = ".tx_test_stat"
    , surveytable.tx_df = ".tx_df"
  )
}

.get_names_count = function() {
  if (getOption("surveytable.raw")) {
    getOption("surveytable.names_count_raw")
  } else {
    getOption("surveytable.names_count")
  }
}

.tx_prct = function(x) {
  if (getOption("surveytable.raw")) return(x * 100)
  round(x * 100, 1)
}

.tx_rate = function(x) {
  if (getOption("surveytable.raw")) return(x)
  round(x, 1)
}

.tx_numeric = function(x) {
  if (getOption("surveytable.raw")) return(x)
  signif(x, 3)
}

.tx_count_1k = function(x) {
  if (getOption("surveytable.raw")) return(x)

  ## Huge UL -> Inf
  x$rat = x$ul / x$x
  idx = which(x$rat > 4e3)
  x$ul[idx] = Inf
  x$rat = NULL

  round(x / 1e3)
}

.tx_count_int = function(x) {
  if (getOption("surveytable.raw")) return(x)

  ## Huge UL -> Inf
  x$rat = x$ul / x$x
  idx = which(x$rat > 4e3)
  x$ul[idx] = Inf
  x$rat = NULL

  round(x)
}

.tx_pval = function(x) {
  if (getOption("surveytable.raw")) return(x)

  round(x, 3)
}

.tx_test_stat = function(x) {
  if (getOption("surveytable.raw")) return(x)

  round(x, 2)
}

.tx_df = function(x) {
  if (getOption("surveytable.raw")) return(x)

  round(x, 1)
}

.tx_none = function(x) {
  x
}
