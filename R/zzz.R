.onAttach = function(libname, pkgname) {
  packageStartupMessage("\nThere are 3 related packages:"
    , "\n* prettysurvey: functions for tabulating survey estimates"
    , "\n* nchsdata: public use files (PUFs) from the the National Center for Health Statistics (NCHS)"
    , "\n* importsurvey: functions for importing data into R"
    , "\n\nYou've just loaded ", pkgname, "."
  )

  packageStartupMessage("* Before you can tabulate estimates, you have to specify which survey"
    , " you would like to use. You can do this in one of several ways:"
    , "\n\na) This package comes with a survey for use in examples called"
    , " 'vars2019'. This survey has selected variables from NAMCS 2019 PUF."
    , " To use this survey:"
    , "\nset_survey('vars2019')"
    , "\n\nb) If you have installed the nchsdata package (which only has public"
    , " use files):"
    , "\nlibrary(nchsdata)"
    , "\nset_survey('survey_name')"
    , "\n\nFor example:"
    , "\nset_survey('namcs2019')"
    , "\n\nTo see the surveys available in nchsdata:"
    , "\nhelp(package = 'nchsdata')"
    , "\n\nc)"
    , "\nsurvey_name = readRDS('file_name.rds')"
    , "\nset_survey('survey_name')"
  )

}

.onLoad = function(libname, pkgname) {
  options(
    prettysurvey.design = ""
    , prettysurvey.design.label = ""

    , prettysurvey.tab.do_present = TRUE
    , prettysurvey.tab.present_restricted = ".present_restricted"
    , prettysurvey.tab.present_count = ".present_count"
    , prettysurvey.tab.present_prop = ".present_prop"

    # , prettysurvey.tab.tx_count = ".tx_count"
    # , prettysurvey.tab.names_count = c("Number (000)", "SE (000)", "LL (000)", "UL (000)")

    , prettysurvey.tab.tx_prct = ".tx_prct"
    , prettysurvey.tab.names_prct = c("Percent", "SE", "LL", "UL")

    , prettysurvey.out.screen = TRUE
    , prettysurvey.out.fname = ""
    , prettysurvey.out.max_levels = 20
  )
  set_count_1k()
}

.tx_prct = function(x) {
  round(x * 100, 1)
}
