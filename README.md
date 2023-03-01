
<!-- README.md is generated from README.Rmd. Please edit that file -->

# prettysurvey

<!-- badges: start -->
<!-- badges: end -->

The goal of prettysurvey is to generate streamlined output from the
`survey` package, with an application to NCHS data.

## Installation

You can install the development version of prettysurvey like so:

``` r
install.packages(c("git2r", "remotes"))

# If you are re-installing this package, first remove it:
remove.packages("prettysurvey")

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
#> prettysurvey
#> * We are still testing this package.
#> * If you notice any issues or if you have ideas for improving it, please let me know.
tab(namcs2019, "AGER")
#>                                         Patient age recode                                         
#> ┌───────────────────┬──────────────┬──────────┬──────────┬──────────┬─────────┬─────┬──────┬──────┐
#> │ Level             │ Number (000) │ SE (000) │ LL (000) │ UL (000) │ Percent │  SE │   LL │   UL │
#> ├───────────────────┼──────────────┼──────────┼──────────┼──────────┼─────────┼─────┼──────┼──────┤
#> │ Under 15 years    │      117,917 │   14,097 │   90,287 │  145,547 │    11.4 │ 1.3 │  8.9 │ 14.2 │
#> ├───────────────────┼──────────────┼──────────┼──────────┼──────────┼─────────┼─────┼──────┼──────┤
#> │ 15-24 years       │       64,856 │    7,018 │   51,100 │   78,611 │     6.3 │ 0.6 │  5.1 │  7.5 │
#> ├───────────────────┼──────────────┼──────────┼──────────┼──────────┼─────────┼─────┼──────┼──────┤
#> │ 25-44 years       │      170,271 │   13,966 │  142,898 │  197,643 │    16.4 │ 1.1 │ 14.3 │ 18.8 │
#> ├───────────────────┼──────────────┼──────────┼──────────┼──────────┼─────────┼─────┼──────┼──────┤
#> │ 45-64 years       │      309,506 │   23,290 │  263,859 │  355,153 │    29.9 │ 1.4 │ 27.2 │ 32.6 │
#> ├───────────────────┼──────────────┼──────────┼──────────┼──────────┼─────────┼─────┼──────┼──────┤
#> │ 65-74 years       │      206,866 │   14,366 │  178,709 │  235,023 │    20   │ 1.2 │ 17.6 │ 22.5 │
#> ├───────────────────┼──────────────┼──────────┼──────────┼──────────┼─────────┼─────┼──────┼──────┤
#> │ 75 years and over │      167,069 │   15,179 │  137,319 │  196,820 │    16.1 │ 1.3 │ 13.7 │ 18.8 │
#> ├───────────────────┴──────────────┴──────────┴──────────┴──────────┴─────────┴─────┴──────┴──────┤
#> │ (No flags.)                                                                                     │
#> └─────────────────────────────────────────────────────────────────────────────────────────────────┘
```
