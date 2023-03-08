#' Show package options
#'
#' @param sw  starting characters
#'
#' @return List of options and their values.
#' @family options
#' @export
#'
#' @examples
#' show_options()
show_options = function(sw = "prettysurvey") {
  op = options()
  idx = op %>% names %>% startsWith(sw)
  op[idx]
}
