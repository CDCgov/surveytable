#' Restructure tables to make them easier to process programmatically
#'
#' Restructure the output of the tabulation functions to make
#' it more structured and easier to process programmatically.
#'
#' Also see [as.data.frame.surveytable_table()] and `set_opts(output = "raw")`.
#'
#' @param tab_output output from a tabulation function. An object of class
#' `surveytable_table` or `surveytable_list`.
#' @param lvls (optional) only show these levels.
#'
#' @returns `data.frame`
#'
#' @family print
#'
#' @export
#'
#' @examples
#' set_survey(namcs2019sv, mode = "nchs")
#'
#' ## total() |> restructure()
#' restructure( total() )
#'
#' ## tab_subset("MAJOR", "AGER") |> restructure(lvls = c("Pre-surgery", "Post-surgery"))
#' mytables = tab_subset("MAJOR", "AGER")
#' restructure(mytables, lvls = c("Pre-surgery", "Post-surgery"))
restructure = function(tab_output, lvls = c()) {
  if (inherits(tab_output, "surveytable_list")) {
    assert_package("restructure", "dplyr")
    ret = list()
    if (length(tab_output) >= 1) {
      for (kk in 1:length(tab_output)) {
        ret[[kk]] = Recall(tab_output = tab_output[[kk]], lvls = lvls)
      }
    }
    return( dplyr::bind_rows(ret) )
  }

  ##
  assert_that(inherits(tab_output, "surveytable_table"))

  ##
  check_attr = getOption("surveytable.restructure_attr")
  if (!is.null(check_attr)) {
    lattr = list()
    for (cc in check_attr) {
      myattr = attr(tab_output, cc)
      if (is.null(myattr)) {
        myattr = NA
      }
      lattr[[cc]] = myattr
    }
  }

  ##
  tab_output %<>% as.data.frame()
  if (!is.null(lvls)) {
    tab_output = tab_output[which(tab_output$Level %in% lvls),]
  }

  ##
  if (!is.null(lattr)) {
    for (cc in names(lattr)) {
      tab_output[, glue(".attr_{cc}")] = lattr[[cc]]
    }
  }

  ##
  if (".attr_title" %in% names(tab_output)) {
    tab_output$.parens1 = NA
    tab_output$.parens2 = NA
    for (ii in 1:nrow(tab_output)) {
      if (grepl("\\(", tab_output$.attr_title[ii])) {
        xx = sub(".*\\(([^)]*)\\).*", "\\1", tab_output$.attr_title[ii])
        if (grepl("=", xx)) {
          xx = trimws(strsplit(xx, "=")[[1]])
          tab_output$.parens1[ii] = xx[1]
          tab_output$.parens2[ii] = xx[2]
        } else {
          tab_output$.parens1[ii] = xx
        }
      }
    }
  }

  ##
  check_flags = getOption("surveytable.restructure_flags")
  if (!is.null(check_flags)) {
    for (jj in check_flags) {
      tab_output[,glue(".flag_{jj}")] = FALSE
    }

    if (!is.null(tab_output$Flags)) {
      for (ii in 1:nrow(tab_output)) {
        if (tab_output$Flags[ii] != "") {
          flags = strsplit(tab_output$Flags[ii], split = " ")[[1]]
          for (jj in flags) {
            if (jj %in% check_flags) {
              tab_output[ii, glue(".flag_{jj}")] = TRUE
            } else if (jj == "") {
            } else {
              warning(glue("{jj}: found unknown flag. Check the surveytable.restructure_flags option."))
            }
          }
        }
      }
    }
    tab_output$Flags = NULL
  }

  tab_output
}
