#' Coerce a surveytable table to a data frame
#'
#' @description
#'
#' If a tabulation function produces multiple tables, that group of tables is a list,
#' with each element of the list being an individual table. To convert one of these tables
#' to a `data.frame`, use `[[`. For example, in the following code, we generate
#' 3 tables, and then convert the third table to a `data.frame`.
#'
#' ```
#' set_survey(namcs2019sv)
#' mytables = tab("MDDO", "SPECCAT", "MSA")
#' mydf = as.data.frame(mytables[[3]])
#' ```
#' @param x a table produced by a tabulation function
#' @param ... ignored
#'
#' @returns
#' A data frame.
#'
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' as.data.frame( tab("AGER") )
as.data.frame.surveytable_table = function(x, ...) {
  class(x) = "data.frame"
  names(x) = make.names( names(x), unique = TRUE )
  x
}
