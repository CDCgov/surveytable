# .onLoad = function(libname, pkgname) {
# }
#
.onAttach = function(libname, pkgname) {
  d0 = "2023-02-28"
  int = 14
  packageStartupMessage(pkgname 
                        , "\n* We are still testing this package." 
                        , "\n* If you notice any issues or if you have ideas for improving it, "
                        , "please let me know.")
  if (difftime(as.Date(Sys.time()), as.Date(d0), units = "days") > int) {
    packageStartupMessage("\n* This version of the package is over ", int, " days old. "
                          , "\n* Please check if there is a newer version.")
  }
}

#' `opts`: options
#' @export
#'
#' @examples
#' opts$out$fname = "output.html"
opts = list()
opts$import$bool.levels = c("yes", "no")
opts$import$bool.true = "yes"

opts$tab$present$restricted = .present_restricted
opts$tab$present$count = .present_count
opts$tab$present$prop = .present_prop

opts$tab$counts_tx = function(x) {round(x / 1e3)}
opts$tab$counts_names = c("Number (000)", "SE (000)"
                          , "LL (000)", "UL (000)")
opts$tab$prct_tx = function(x) {round(x * 100, 1)}
opts$tab$prct_names = c("Percent", "SE", "LL", "UL")

opts$out$fname = ""
opts$out$hux_format = .hux_format
