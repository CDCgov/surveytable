#' List variables in a survey.
#'
#' @param sw      starting characters in variable name (case insensitive)
#' @param all     print all variables?
#' @param screen  print to the screen?
#' @param csv     name of a CSV file
#'
#' @return `data.frame`
#' @export
#'
#' @examples
#' set_survey("vars2019")
#' var_list("age")
var_list = function(sw = "", all=FALSE
                    , screen = getOption("prettysurvey.screen")
                    , csv = getOption("prettysurvey.csv")
) {
  design = .load_survey()
  assert_that(nzchar(sw) | all
              , msg = "Either set the 'sw' argument to a non-empty string, or set all=TRUE")
  nn = names(design$variables)
  if (!all) {
    sw %<>% tolower
    idx = nn %>% tolower %>% startsWith(sw)
    nn = nn[idx]
  }

  ret = NULL
  for (ii in nn) {
    r1 = data.frame(
      Variable = ii
      , Class = paste(class(design$variables[,ii])
                      , collapse = ", ")
      , Label = .getvarname(design, ii)
    )
    ret %<>% rbind(r1)
  }

  ret = if (is.null(ret)) {
    data.frame(Note = "No variables found.")
  } else {
    ret[order(ret$Variable), ]
  }
  attr(ret, "title") = if (all) {
    "ALL variables"
  } else {
    paste0("Variables beginning with '", sw, "'")
  }
  .write_out(ret, screen = screen, csv = csv)
}

.getvarname = function(design, vr) {
  nm = attr(design$variables[,vr], "label")
  if (is.null(nm)) nm = vr
  nm
}
