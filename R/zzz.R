.onAttach = function(libname, pkgname) {
  d0 = "2023-03-03"
  int = 14
  packageStartupMessage(pkgname
                        , "\n* We are still testing this package."
                        , "\n* If you notice any issues or if you have ideas for improving it, "
                        , "please let me know.")
  if (difftime(as.Date(Sys.time()), as.Date(d0), units = "days") > int) {
    packageStartupMessage("\n* This version of the package is over ", int, " days old. "
                          , "\n* Please check if there is a newer version."
                          , "\n* Instructions for re-installing https://git.biotech.cdc.gov/kpr9/prettysurvey/-/blob/master/README.md"
                          )
  }
}

.onLoad = function(libname, pkgname) {
  options(
    prettysurvey.import.bool_levels = c("yes", "no")
    , prettysurvey.import.bool_true = "yes"

    , prettysurvey.tab.do_present = TRUE
    , prettysurvey.tab.present_restricted = ".present_restricted"
    , prettysurvey.tab.present_count = ".present_count"
    , prettysurvey.tab.present_prop = ".present_prop"
    , prettysurvey.tab.tx_count = ".tx_count"
    , prettysurvey.tab.tx_prct = ".tx_prct"

    , prettysurvey.tab.names_count = c("Number (000)", "SE (000)", "LL (000)", "UL (000)")
    , prettysurvey.tab.names_prct = c("Percent", "SE", "LL", "UL")

    , prettysurvey.out.screen = TRUE
    , prettysurvey.out.fname = ""
    , prettysurvey.out.max_levels = 20
  )
}
