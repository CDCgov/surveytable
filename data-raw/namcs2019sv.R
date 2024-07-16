library(nchsdata)
library(magrittr)

vrs = c("CPSUM", "CSTRATM", "PATWT" # survey design
        , "MDDO", "SPECCAT", "MSA"  # Table 1
        , "AGER", "SEX", "AGE"      # Table 3
        , "NOPAY", "PAYPRIV", "PAYMCARE", "PAYMCAID", "PAYWKCMP"
        , "PAYOTH", "PAYDK", "PAYSELF", "PAYNOCHG" # Table 5
        , "PRIMCARE", "REFER", "SENBEFOR" # Table 6
        , "MAJOR" # Table 11
        , "NUMMED" # numeric variable
        , "ANYIMAGE", "BONEDENS", "CATSCAN", "ECHOCARD", "OTHULTRA"
        , "MAMMO", "MRI", "XRAY", "OTHIMAGE" # imaging
)  %>% unique

namcs2019sv_df = namcs2019$variables[,vrs]

vr = "SPECCAT.bad"
namcs2019sv_df[,vr] = namcs2019sv_df$SPECCAT
set.seed(42)
nr = nrow(namcs2019sv_df)
idx = sample.int(n = nr, size = round(0.2 * nr))
namcs2019sv_df[idx, vr] = NA
attr(namcs2019sv_df[,vr], "label") = "Type of specialty (BAD - do not use)"

namcs2019sv = survey::svydesign(ids = ~ CPSUM, strata = ~ CSTRATM, weights = ~ PATWT
  , data = namcs2019sv_df)
attr(namcs2019sv, "label") = "NAMCS 2019 PUF"

usethis::use_data(namcs2019sv, overwrite = TRUE)
usethis::use_data(namcs2019sv_df, overwrite = TRUE)
