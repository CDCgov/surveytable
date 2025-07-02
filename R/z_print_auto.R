.print_auto = function(df1, destination = NULL, ...) {
  dest = .get_destination(destination = destination)
  assert_that(dest %in% c("", "html", "latex"))

  if (dest == "") {
    .print_huxtable(df1, destination = dest, ...)
  } else if (dest == "html") {
    .print_gt(df1, destination = dest, ...)
  } else if (dest == "latex") {
    .print_kableextra(df1, destination = dest, ...)
  } else {
    stop("?")
  }
}
