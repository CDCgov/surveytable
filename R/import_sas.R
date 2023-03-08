#' Import SAS data into R
#'
#' @param sas_data  SAS survey data file
#' @param sas_formats_data    SAS formats data file (produced with CNTLOUT option of PROC FORMAT)
#'
#' @return `data.frame`. If this is a complex survey, use `svydesign` to
#' create a survey design object.
#' @family import
#' @export
#'
#' @examples
#' \dontrun{
#' d1 = import_sas(sas_data, sas_formats_data)
#' }
import_sas = function(sas_data, sas_formats_data) {
  df1 = read_sas(sas_formats_data) %>% as.data.frame
  assert_that(all(df1$START == df1$END))
  df1 = df1[,c("FMTNAME", "START", "LABEL")]
  df1$START %<>% trimws
  df1$LABEL %<>% trimws

  d1 = read_sas(sas_data) %>% as.data.frame
  c.nofmt = c.2v = c.log = c()
  for (ii in names(d1)) {
    fmt = attr(d1[,ii], "format.sas")
    if (is.null(fmt)) {
      c.nofmt %<>% c(ii)
      d1[,ii] %<>% .c2f
      next
    }
    if (fmt %>% startsWith("$")) {
      fmt %<>% substring(2)
    }
    if (length(fmt) == 1L && nzchar(fmt)) {
      lbl = attr(d1[,ii], "label")
      idx = which(df1$FMTNAME == fmt)
      if (length(idx) > 0) {
        f1 = df1[idx,]
        if (inherits(d1[,ii], "difftime")) {
          d1[,ii] %<>% as.numeric
        }
        if (is.numeric(d1[,ii])) {
          f1$START %<>% as.numeric %>% suppressWarnings
        }
        if (is_subset(unique(d1[,ii]), f1$START)) {
          # Normal
          d1[,ii] %<>% factor(
            levels = f1$START
            , labels = f1$LABEL
            , exclude = NULL) %>% addNA(ifany = TRUE)
          attr(d1[,ii], "label") = lbl
        } else {
          # raw
          vn = paste0(ii, ".raw")
          d1[,vn] = d1[,ii] %>% .c2f
          attr(d1[,vn], "label") = paste(lbl, "(raw - use caution)")

          # special values
          vn = paste0(ii, ".special")
          d1[,vn] = factor(x = d1[,ii]
                           , levels = f1$START
                           , labels = f1$LABEL
                           , exclude = NULL) %>% addNA(ifany = TRUE)
          attr(d1[,vn], "label") = paste(lbl, "(defined levels only, NA = non-special - use caution)")

          # no special values
          vn = paste0(ii, ".nospecial")
          d1[,vn] = d1[,ii]
          d1[which(d1[,vn] %in% f1$START),vn] = NA
          d1[,vn] %<>% .c2f
          attr(d1[,vn], "label") = paste(lbl, "(NA = special values - use caution)")

          c.2v %<>% c(ii)
        }
      } else {
        stop(ii, ": format specified but not defined")
      }
    } else {
      stop(ii, ": format specified incorrectly")
    }
  }

  op.bl = getOption("prettysurvey.import.bool_levels") %>% tolower %>% trimws
  op.bt = getOption("prettysurvey.import.bool_true") %>% tolower %>% trimws
  options(prettysurvey.import.bool_levels = op.bl
          , prettysurvey.import.bool_true = op.bt)
  for (ii in names(d1)) {
    if (is.factor(d1[,ii]) && nlevels(d1[,ii]) == 2L) {
      lvl = levels(d1[,ii]) %>% tolower %>% trimws
      if(lvl %>% setequal( getOption("prettysurvey.import.bool_levels") )) {
        c.log %<>% c(ii)
        lbl = attr(d1[,ii], "label")
        d1[,ii] = (tolower(d1[,ii]) == getOption("prettysurvey.import.bool_true") )
        attr(d1[,ii], "label") = lbl
      }
    }
  }
  d1[,c.2v] = NULL

  if (length(c.nofmt) > 0) {
    c.nofmt %>% paste(collapse=", ") %>% paste("Variables that have no format:", .) %>% message
  }
  if (length(c.2v) > 0) {
    c.2v %>% paste(collapse=", ") %>% paste("Format applies only to some values, created multiple version of variable:", .) %>% message
  }
  if (length(c.log) > 0) {
    c.log %>% paste(collapse=", ") %>% paste("Yes/no variable - converted to logical:", .) %>% message
  }

  assert_that(
    all(d1 %>% sapply(class) %in% c("factor", "logical", "numeric"))
  )
  d1
}

# https://stackoverflow.com/questions/37656853/how-to-check-if-set-a-is-subset-of-set-b-in-r
is_subset = function(A,B) {
  setequal(intersect(A,B), A)
}

.c2f = function(x) {
  if (is.character(x)) {
    x %<>% factor(exclude = NULL) %>% addNA(ifany = TRUE)
  }
  x
}
