
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
#>                                Patient age recode                               
#>     ┌──────────┬──────────┬──────────┬──────────┬──────────┬─────────┬─────┐
#>     │ Level    │   Number │ SE (000) │ LL (000) │ UL (000) │ Percent │  SE │
#>     │          │    (000) │          │          │          │         │     │
#>     ├──────────┼──────────┼──────────┼──────────┼──────────┼─────────┼─────┤
#>     │ Under 15 │  117,917 │   14,097 │   90,287 │  145,547 │    11.4 │ 1.3 │
#>     │ years    │          │          │          │          │         │     │
#>     ├──────────┼──────────┼──────────┼──────────┼──────────┼─────────┼─────┤
#>     │ 15-24    │   64,856 │    7,018 │   51,100 │   78,611 │     6.3 │ 0.6 │
#>     │ years    │          │          │          │          │         │     │
#>     ├──────────┼──────────┼──────────┼──────────┼──────────┼─────────┼─────┤
#>     │ 25-44    │  170,271 │   13,966 │  142,898 │  197,643 │    16.4 │ 1.1 │
#>     │ years    │          │          │          │          │         │     │
#>     ├──────────┼──────────┼──────────┼──────────┼──────────┼─────────┼─────┤
#>     │ 45-64    │  309,506 │   23,290 │  263,859 │  355,153 │    29.9 │ 1.4 │
#>     │ years    │          │          │          │          │         │     │
#>     ├──────────┼──────────┼──────────┼──────────┼──────────┼─────────┼─────┤
#>     │ 65-74    │  206,866 │   14,366 │  178,709 │  235,023 │    20   │ 1.2 │
#>     │ years    │          │          │          │          │         │     │
#>     ├──────────┼──────────┼──────────┼──────────┼──────────┼─────────┼─────┤
#>     │ 75 years │  167,069 │   15,179 │  137,319 │  196,820 │    16.1 │ 1.3 │
#>     │ and over │          │          │          │          │         │     │
#>     └──────────┴──────────┴──────────┴──────────┴──────────┴─────────┴─────┘
#>       (No flags.)                                                           
#> 
#> 7/9 columns shown.
```
