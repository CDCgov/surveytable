#' Rounding counts
#'
#' Determines how counts should be rounded.
#'
#' * `set_count_1k()`: round counts to the nearest 1,000.
#' * `set_count_int()`: round counts to the nearest integer.
#'
#' @return (Nothing.)
#' @family options
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' set_count_int()
#' total()
#'
#' set_count_1k()
#' total()
set_count_1k = function() {
  # If making changes, update .onLoad()
  options(
    surveytable.tx_count = ".tx_count_1k"
    , surveytable.names_count = c("Number (000)", "SE (000)", "LL (000)", "UL (000)")
  )
  message(paste0("* Rounding counts to the nearest 1,000."
             , "\n* ?set_count_1k for other options."))
}

#' @rdname set_count_1k
#' @export
set_count_int = function() {
  options(
    surveytable.tx_count = ".tx_count_int"
    , surveytable.names_count = c("Number", "SE", "LL", "UL")
  )
  message(paste0("* Rounding counts to the nearest integer."
                 , "\n* ?set_count_int for other options."))
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
