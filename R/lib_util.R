#' Show package options
#'
#' @return List of options and their values.
#' @export
#'
#' @examples
#' show_options()
show_options = function() {
  op = options()
  idx = op %>% names %>% startsWith("prettysurvey")
  op[idx]
}
