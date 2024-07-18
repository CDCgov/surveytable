#' Show package options
#'
#' See [surveytable-options] for a discussion of some of the options.
#'
#' @param sw  starting characters
#'
#' @return List of options and their values.
#' @family options
#' @export
#'
#' @examples
#' show_options()
show_options = function(sw = "surveytable") {
  op = options()
  idx = op %>% names %>% startsWith(sw)
  op[idx]
}
