.onAttach = function(libname, pkgname) {
  # packageStartupMessage("\nThere are 3 related packages:"
  #   , "\n* surveytable: functions for tabulating survey estimates"
  #   , "\n* nchsdata: public use files (PUFs) from the the National Center for Health Statistics (NCHS)"
  #   , "\n* importsurvey: functions for importing data into R"
  #   , "\n\nYou've just loaded ", pkgname, "."
  # )

  packageStartupMessage("Before you can tabulate estimates, you have to specify which survey object"
    , " you would like to analyze. You can do this in a couple of ways:"
    , "\n\na) This package comes with a survey object for use in examples called"
    , " 'namcs2019sv'. This object has selected variables from the NAMCS 2019 PUF survey."
    , " To use this survey object:"
    , "\n\nset_survey('namcs2019sv')"
    , "\n\nb) If you have a survey object stored in a file:"
    , "\n\nmysurvey = readRDS('file_name.rds')"
    , "\nset_survey('mysurvey')"
    , "\n\nFor info on how to create a survey object from a data frame, see"
    , " ?survey::svydesign or ?survey::svrepdesign ."
  )
}

.onLoad = function(libname, pkgname) {
  options(
    surveytable.survey = ""
    , surveytable.survey_label = ""
    , surveytable.survey_envir = .GlobalEnv

    , surveytable.check_present = TRUE
    , surveytable.present_restricted = ".present_restricted"
    , surveytable.present_count = ".present_count"
    , surveytable.present_prop = ".present_prop"

    , surveytable.tx_count = ".tx_count_1k"
    , surveytable.names_count = c("Number (000)", "SE (000)", "LL (000)", "UL (000)")

    , surveytable.tx_prct = ".tx_prct"
    , surveytable.names_prct = c("Percent", "SE", "LL", "UL")

    , surveytable.csv = ""
    , surveytable.screen = TRUE
    , surveytable.max_levels = 20
    , surveytable.drop_na = FALSE

    , surveytable.rate_per = 100
    , surveytable.tx_rate = ".tx_rate"

    , surveytable.adjust_svyciprop = FALSE
    , surveytable.adjust_svyciprop.df_method = "NHIS"

    , surveytable.svychisq_statistic = "Wald"
  )
  # No - creates a startup message which cannot be suppressed.
  # set_count_1k()
}

.tx_prct = function(x) {
  round(x * 100, 1)
}

.tx_rate = function(x) {
  round(x, 1)
}
