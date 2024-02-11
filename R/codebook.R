#' Create a codebook for the survey
#'
#' @param all tabulate all the variables?
#' @param csv name of a CSV file
#'
#' @return A list of tables.
#' @export
#'
#' @examples
#' set_survey(namcs2019sv)
#' codebook()
codebook = function(all = FALSE
    , csv = getOption("surveytable.csv")) {
  design = .load_survey()
  lret = list()
  lret[[1]] = set_survey(design, csv = csv)

  nn = names(design$variables)
  nr = nrow(design$variables)

  ret = NULL
  c.f2c = c()
  c.c2f = c()
  for (ii in 1:ncol(design$variables)) {
    r1 = data.frame(`Item no.` = ii
            , Variable = nn[ii]
            , Description = attr(design$variables[,ii], "label")
            , Class = paste(class(design$variables[,ii])
                            , collapse = ", ")
            , `Missing (%)` = round(100 *
                  sum(is.na(design$variables[,ii])) / nr, 1)
            , check.names = FALSE
            )
    if(design$variables[,ii] %>% is.factor) {
      nlvl = design$variables[,ii] %>% nlevels
      if (nlvl > 20) {
        c.f2c %<>% c(nn[ii])
      }
      lvl1 = design$variables[,ii] %>% levels
      lvl2 = design$variables[,ii] %>% droplevels %>% levels
      dx = setdiff(lvl1, lvl2)
      if (length(dx) > 0) {
        message(paste0("* ", nn[ii], " has empty levels: "
                       , dx %>% paste(collapse = ", ")))
      }
      r1$Values = lvl1 %>% paste(collapse = ", ")
    } else if(design$variables[,ii] %>% is.logical) {
      r1$Values = ""
    } else { # numeric, character, all others
      mn = min(design$variables[,ii], na.rm = TRUE)
      mx = max(design$variables[,ii], na.rm = TRUE)
      if (mx > mn) {
        r1$Values = paste0(mn, " - ", mx)
      } else {
        assert_that(are_equal(mn, mx))
        r1$Values = mn
      }

      if (design$variables[,ii] %>% is.character) {
        fo = design$variables[,ii] %>% unique
        if (length(fo) <= 20) {
          c.c2f %<>% c(nn[ii])
        }
      }
    }
    ret %<>% rbind(r1)
  }

  if (length(c.f2c) > 0) {
    message(paste0("* These factor variables have a lot of levels."
      , " Should they be character? "
      , c.f2c %>% paste0(collapse = ", ")))
  }
  if (length(c.c2f) > 0) {
    message(paste0("* These character variables have few unique values."
       , " Should they be factor? "
       , c.c2f %>% paste0(collapse = ", ")))
  }

  attr(ret, "title") = "Codebook"
  attr(ret, "num") = 5
  lret[[2]] = .write_out(ret, csv = csv)

  if (all) {
    op_ = options(surveytable.check_present = FALSE)
    on.exit(options(op_))
    for (ii in 1:ncol(design$variables)) {
      n1 = nn[ii]
      lbl0 = attr(design$variables[,ii], "label")
      lbl1 = paste0(ii, ". ", n1)
      if (!is.null(lbl0)) {
        lbl1 %<>% paste0(" (", lbl0, ")")
      }

      attr(env$survey$variables[,ii], "label") = lbl1
      lret[[n1]] = tab(n1
                       , test = FALSE
                       , drop_na = FALSE
                       , max_levels = Inf
                       , csv = csv)
      attr(env$survey$variables[,ii], "label") = lbl0
    }
  }

  class(lret) = "surveytable_list"
  lret
}
