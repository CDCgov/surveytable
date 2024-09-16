# .onAttach = function(libname, pkgname) {
#   txt = paste0(
#     "Before you can tabulate estimates, you have to specify which survey object"
#     , " you would like to analyze. You can do this in a couple of ways:"
#     , "\n\na) This package comes with a survey object for use in examples called"
#     , " 'namcs2019sv'. This object has selected variables from the NAMCS 2019 PUF survey."
#     , " To use this survey object:"
#     , "\n\nset_survey(namcs2019sv)"
#     , "\n\nb) If you have a survey object stored in a file:"
#     , "\n\nmysurvey = readRDS('file_name.rds')"
#     , "\n\nset_survey(mysurvey)"
#     , "\n\nFor info on how to create a survey object from a data frame, see"
#     , " ?survey::svydesign or ?survey::svrepdesign ."
#   )
#
#   txt = paste(strwrap(txt), collapse = "\n")
#   packageStartupMessage(txt)
# }

env = new.env()

.onLoad = function(libname, pkgname) {
  options(
    surveytable.survey_label = ""

    ## set_opts(mode = "general")
    , surveytable.tx_count = ".tx_count_int"
    , surveytable.names_count = c("n", "Number", "SE", "LL", "UL")
    , surveytable.find_lpe = FALSE
    , surveytable.adjust_svyciprop = FALSE

    ## related
    , surveytable.lpe_n = ".lpe_n"
    , surveytable.lpe_counts = ".lpe_counts"
    , surveytable.lpe_percents = ".lpe_percents"
    , surveytable.adjust_svyciprop.df_method = "NHIS"

    ## other set_opts()
    , surveytable.drop_na = FALSE
    , surveytable.max_levels = 20
    , surveytable.csv = ""

    ## other
    , surveytable.tx_prct = ".tx_prct"
    , surveytable.names_prct = c("Percent", "SE", "LL", "UL")

    , surveytable.rate_per = 100
    , surveytable.tx_rate = ".tx_rate"

    , surveytable.tx_numeric = ".tx_numeric"

    , surveytable.svychisq_statistic = "F"
    , surveytable.p.adjust_method = "bonferroni"
  )
}

.tx_prct = function(x) {
  round(x * 100, 1)
}

.tx_rate = function(x) {
  round(x, 1)
}

.tx_numeric = function(x) {
  signif(x, 3)
}

.tx_count_1k = function(x) {
  ## Huge UL -> Inf
  x$rat = x$ul / x$x
  idx = which(x$rat > 4e3)
  x$ul[idx] = Inf
  x$rat = NULL

  round(x / 1e3)
}
.tx_count_int = function(x) {
  ## Huge UL -> Inf
  x$rat = x$ul / x$x
  idx = which(x$rat > 4e3)
  x$ul[idx] = Inf
  x$rat = NULL

  round(x)
}
.tx_count_none = function(x) {
  x
}
