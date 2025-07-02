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
#' The package used to produce the tables can be changed -- see the `output` argument
#' of [set_opts()] for details. By default, the table-making package `huxtable` is used.
#'
#' @param x an object of class `surveytable_table` or `surveytable_list`.
#' @param ... passed to helper functions.
#'
#' @return
#' Returns `x` invisibly.
#'
#' @family print
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
  getOption("surveytable.print") %>% do.call( list(x, ...) )
  invisible(x)
}

#' @rdname print.surveytable_table
#' @order 2
#' @export
print.surveytable_list = print.surveytable_table
