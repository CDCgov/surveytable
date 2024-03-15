#' @import assertthat
#' @import magrittr
#' @import survey
#' @importFrom huxtable guess_knitr_output_format hux set_all_borders caption caption<- number_format number_format<- fmt_pretty add_footnote print_screen print_html
#' @importFrom kableExtra kbl kable_styling footnote column_spec
#' @importFrom stats as.formula confint qt coef pt
#' @importFrom utils write.table tail capture.output
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' Package options
#'
#' Run [`show_options()`] to see available options. Here is a description of some
#' notable options.
#'
#' **Low-precision estimates.**
#'
#' * `surveytable.find_lpe`: should the tabulation functions look for low-precision
#' estimates? You can change this directly with `options()` or with the `opts` argument
#' to `set_survey()`.
#' * `surveytable.lpe_n`, `surveytable.lpe_counts`, `surveytable.lpe_percents`: names
#' of 3 functions.
#'
#' The argument for `surveytable.lpe_n` is a vector of the number of observations
#' for each level of the variable.
#'
#' The argument for `surveytable.lpe_counts` is a data frame with count-related estimates.
#' Specifically, the data frame has the following variables:
#'
#' * `x`: point estimates of counts
#' * `s`: SE
#' * `ll`, `ul`: CI
#' * `samp.size`: effective sample size
#' * `counts`: actual sample size
#' * `degf`: degrees of freedom
#'
#' The argument for `surveytable.lpe_percents` is a data frame with percent-related
#' estimates. Specifically, the data frame has the following variables:
#'
#' * `Proportion`: point estimates of proportions (between `0` and `1`)
#' * `SE`: SE
#' * `LL`, `UL`: CI
#' * `n numerator`: the number of observations for which the variable is `TRUE`
#' * `n denominator`: the total number of observations
#'
#' Each of these functions must return a list with the following elements:
#'
#' * `id`: the name of the algorithm used, such as `"NCHS presentation standards"`
#' * `flags`: a vector. For each level of the variable, short codes indicating the presence of
#' low-precision estimates.
#' * `has.flag`: a vector of short codes that are present in `flags`.
#' * `descriptions`: a named vector. The names must be the short codes, the values are
#' the longer descriptions.
#'
#' For example, if a variable has 3 levels, `flags` might be `c("", "A1 A2", "")`. This
#' indicates that for the first and third level, nothing was found, whereas for the second
#' level, two different things were found, indicated by short codes `A1` and `A2`. In
#' this case, `has.flag = c("A1", "A2")`, `descriptions = c(A1 = "A1: something", A2 = "A2: something else")`.
#'
#'
#' @name surveytable-options
#' @family options
"_PACKAGE"
