#' @import assertthat
#' @import magrittr
#' @import glue
#' @import survey
#' @importFrom stats as.formula confint qt coef pt p.adjust
#' @importFrom utils write.table tail capture.output
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' Package options
#'
#' This article is for more advanced users. Typical users, see [set_opts()]
#' and [show_opts()] to set and show certain options.
#'
#' To view all available options, use [show_options()]. Below is a description
#' of some noteworthy options.
#'
#' ## Printing using various table-making packages
#'
#' The tabulation functions return objects of class `surveytable_table` (for a single
#' table) or `surveytable_list` (for multiple tables, which is just a list of `surveytable_table`
#' objects). A `surveytable_table` object is just a `data.frame` with the following
#' attributes: `title`, `footer`, and `num`, which is the index of columns that
#' should be formatted as a number.
#'
#' Naturally, these objects can be printed using a variety of packages. `surveytable`
#' ships with the ability to use `huxtable`, `gt`, or `kableExtra`. See the `output`
#' argument of [set_opts()].
#'
#' You can supply custom code to use another table-making package or to use one of these
#' table-making packages, but in a different way. The two relevant options are `surveytable.output_object`
#' and `surveytable.output_print`.
#'
#' `surveytable.output_object` is the name of a function with the following arguments:
#' `x` and `...`, where `x` is a `surveytable_table` object. This function returns
#' an object from a table-making package, for example, it returns a `gt` object. Be sure
#' that this package is installed.
#'
#' `surveytable.output_print` is the name of a function with the following arguments:
#' `x` and `...`, where `x` is an object returned by the `surveytable.output_object`
#' function. The `surveytable.output_print` function prints this object.
#'
#' For an example of how this works, see the internal functions `surveytable:::.as_object_huxtable`
#' and `surveytable:::.print_huxtable`.
#'
#' ## Low-precision estimates
#'
#' Optionally, all of the tabulation functions can identify low-precision estimates.
#' Turn on this functionality using any of the following: [set_opts](lpe = TRUE),
#' [set_opts](mode = "nchs"), [set_survey](*, mode = "nchs"), or `options(surveytable.find_lpe = TRUE)`.
#'
#' By default, low-precision estimates are identified using National Center for
#' Health Statistics (NCHS) algorithms. However, this can be changed, as described
#' below.
#'
#' Here is a description of the options related to the identification of low-precision
#' estimates.
#'
#' * `surveytable.find_lpe`: should the tabulation functions look for low-precision
#' estimates? You can change this directly with `options()` or with either [set_opts()]
#' or [set_survey()].
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
#' @name surveytable-options
#' @family options
"_PACKAGE"
