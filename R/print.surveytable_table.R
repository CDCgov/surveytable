#' Print surveytable tables
#'
#' @description
#'
#' If a tabulation function is called from the top level, it should print out
#' its table(s) on its own. If that tabulation function is called not from the
#' top level, such as from within a loop or another function, you need to call
#' `print()` explicitly. For example:
#'
#' ```
#' set_survey(namcs2019sv)
#' for (vr in c("AGER", "SEX")) {
#'   print( tab_subset(vr, "MAJOR", "Preventive care") )
#' }
#' ```
#'
#' @details
#'
#' The package used to produce the tables can be changed. See [set_opts()] for
#' details. By default, `huxtable` is used.
#'
#' `as_object()` returns an object (or a list of objects) of whatever package
#' is being used for printing (such as `huxtable`). This is useful for further
#' customizing the tables before finally printing them.
#'
#' @param x an object of class `surveytable_table` or `surveytable_list`.
#' @param ... passed to helper functions.
#'
#' @return
#' `print.*` returns `x` invisibly.
#'
#' `as_object()` returns an object (or a list of objects) of whatever package
#' is being used for printing (such as `huxtable`).
#'
#' @order 1
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' table1 = tab("AGER")
#' print(table1)
#' table_many = tab("MDDO", "SPECCAT", "MSA")
#' print(table_many)
print.surveytable_table = function(x, ...) {
  obj = as_object(x, ...)
  getOption("surveytable.output_print") %>% do.call( list(obj, ...) )
  invisible(x)
}

#' @rdname print.surveytable_table
#' @order 2
#' @export
print.surveytable_list = function(x, ...) {
  obj = as_object(x, ...)
  if (length(obj) > 0) {
    for (ii in 1:length(obj)) {
      getOption("surveytable.output_print") %>% do.call( list(obj[[ii]], ...) )
    }
  }
  invisible(x)
}

#' @rdname print.surveytable_table
#' @order 3
#' @export
as_object = function(x, ...) {
  assert_that(inherits(x, "surveytable_table") || inherits(x, "surveytable_list"))

  if (inherits(x, "surveytable_table")) {
    ret = getOption("surveytable.output_object") %>% do.call( list(x, ...) )
    return(ret)
  } else {
    ret = list()
    if (length(x) > 0) {
      for (ii in 1:length(x)) {
        ret[[ii]] = getOption("surveytable.output_object") %>% do.call( list(x[[ii]], ...) )
      }
    }
    return(ret)
  }
}
