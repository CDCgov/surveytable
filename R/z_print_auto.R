.as_object_auto = function(df1, destination = NULL, ...) {
  dest = .get_destination(destination = destination)
  assert_that(dest %in% c("", "html", "latex"))

  if (dest == "") {
    .as_object_huxtable(df1, ...)
  } else if (dest == "html") {
    .as_object_gt(df1, ...)
  } else if (dest == "latex") {
    .as_object_kableextra(df1, destination = "latex", ...)
  }
}

.print_auto = function(hh, destination = NULL, ...) {
  dest = .get_destination(destination = destination)
  assert_that(dest %in% c("", "html", "latex"))

  if (dest == "") {
    .print_huxtable(hh, destination = "", ...)
  } else if (dest == "html") {
    .print_gt(hh, destination = "html", ...)
  } else if (dest == "latex") {
    .print_kableextra(hh, ...)
  }
}
