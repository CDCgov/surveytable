#' Deprecated functions
#'
#' `r lifecycle::badge("deprecated")`
#'
#' Use [set_opts()] instead of any of the following: `set_mode()`, `set_count_1k()`,
#' `set_count_int()`, `set_output()`.
#'
#' @export
#' @keywords internal
#' @name deprecated
#' @rdname deprecated
set_mode = function(mode = "general") {
  lifecycle::deprecate_soft("0.9.5", "set_mode()", "set_opts()")
  set_opts(mode = mode)
}

#' @export
#' @keywords internal
#' @rdname deprecated
set_count_1k = function() {
  lifecycle::deprecate_soft("0.9.5", "set_count_1k()", "set_opts()")
  set_opts(count = "1k")
}

#' @export
#' @keywords internal
#' @rdname deprecated
set_count_int = function() {
  lifecycle::deprecate_soft("0.9.5", "set_count_int()", "set_opts()")
  set_opts(count = "int")
}

#' @export
#' @keywords internal
#' @rdname deprecated
set_output = function(drop_na = NULL, max_levels = NULL, csv = NULL) {
  lifecycle::deprecate_soft("0.9.5", "set_output()", "set_opts()")
  set_opts(drop_na = drop_na, max_levels = max_levels, csv = csv)
}
