
<!-- README.md is generated from README.Rmd. Please edit that file -->

# prettysurvey

<!-- badges: start -->
<!-- badges: end -->

The goal of prettysurvey is to generate streamlined output from the
`survey` package, with an application to NCHS.

## Installation

You can install the development version of prettysurvey like so:

``` r
install.packages(c("git2r", "remotes"))

# On local computer
remotes::install_git(
    url = "https://git.biotech.cdc.gov/kpr9/prettysurvey"
    , git = "git2r"
    , upgrade = "never")

# On EDAV RStudio
remotes::install_git(
    url = "https://git.biotech.cdc.gov/kpr9/prettysurvey"
    , upgrade = "never")
```

## Example

This is a basic example:

``` r
library(prettysurvey)
#> * Rounding counts to the nearest 1,000.
#> * ?set_count_1k for other options.
#> 
#> There are 3 related packages:
#> * prettysurvey: functions for tabulating survey estimates
#> * nchsdata: public use files (PUFs) from the the National Center for Health Statistics (NCHS)
#> * importsurvey: functions for importing data into R
#> 
#> You've just loaded prettysurvey.
#> * Before you can tabulate estimates, you have to specify which survey you would like to use. You can do this in one of several ways:
#> 
#> a) This package comes with a survey for use in examples called 'vars2019'. This survey has selected variables from NAMCS 2019 PUF. To use this survey:
#> set_survey('vars2019')
#> 
#> b) If you have installed the nchsdata package (which only has public use files):
#> library(nchsdata)
#> set_survey('survey_name')
#> 
#> For example:
#> set_survey('namcs2019')
#> 
#> To see the surveys available in nchsdata:
#> help(package = 'nchsdata')
#> 
#> c)
#> survey_name = readRDS('file_name.rds')
#> set_survey('survey_name')
set_survey("vars2019")
#> * Analyzing vars2019
#> Stratified 1 - level Cluster Sampling design (with replacement)
#> With (398) clusters.
#> sdo = svydesign(ids = ~ CPSUM
#>                   , strata = ~ CSTRATM
#>                   , weights = ~ PATWT
#>                   , data = d1)
#> * To adjust how counts are rounded, see ?set_count_int
tab("AGER")
#>                                  Patient age recode [vars2019]                                 
#> +---------------------------------------------------------------------------------------------+
#> ¦ Level         ¦ Number (000) ¦ SE (000) ¦ LL (000) ¦ UL (000) ¦ Percent ¦  SE ¦   LL ¦   UL ¦
#> +---------------+--------------+----------+----------+----------+---------+-----+------+------¦
#> ¦ Under 15      ¦      117,917 ¦   14,097 ¦   90,287 ¦  145,547 ¦    11.4 ¦ 1.3 ¦  8.9 ¦ 14.2 ¦
#> ¦ years         ¦              ¦          ¦          ¦          ¦         ¦     ¦      ¦      ¦
#> +---------------+--------------+----------+----------+----------+---------+-----+------+------¦
#> ¦ 15-24 years   ¦       64,856 ¦    7,018 ¦   51,100 ¦   78,611 ¦     6.3 ¦ 0.6 ¦  5.1 ¦  7.5 ¦
#> +---------------+--------------+----------+----------+----------+---------+-----+------+------¦
#> ¦ 25-44 years   ¦      170,271 ¦   13,966 ¦  142,898 ¦  197,643 ¦    16.4 ¦ 1.1 ¦ 14.3 ¦ 18.8 ¦
#> +---------------+--------------+----------+----------+----------+---------+-----+------+------¦
#> ¦ 45-64 years   ¦      309,506 ¦   23,290 ¦  263,859 ¦  355,153 ¦    29.9 ¦ 1.4 ¦ 27.2 ¦ 32.6 ¦
#> +---------------+--------------+----------+----------+----------+---------+-----+------+------¦
#> ¦ 65-74 years   ¦      206,866 ¦   14,366 ¦  178,709 ¦  235,023 ¦    20   ¦ 1.2 ¦ 17.6 ¦ 22.5 ¦
#> +---------------+--------------+----------+----------+----------+---------+-----+------+------¦
#> ¦ 75 years and  ¦      167,069 ¦   15,179 ¦  137,319 ¦  196,820 ¦    16.1 ¦ 1.3 ¦ 13.7 ¦ 18.8 ¦
#> ¦ over          ¦              ¦          ¦          ¦          ¦         ¦     ¦      ¦      ¦
#> +---------------------------------------------------------------------------------------------+
#>   (No flags.)
```
