## data_path =

library(dplyr)
library(magrittr)
library(survey)

his24a = haven::read_sas( file.path(data_path, "adult24.sas7bdat") )
names(his24a) <- tolower(names(his24a))

####################################################################
# STEP 1: Read Data and Construct Analysis Variables
####################################################################

################################################################################
############ Create 3-Category Functioning Variable ############################
################################################################################

# Vision
his24a <- his24a |>
  mutate(vision = case_when(
    visiondf_a %in% c(1, 2) ~ visiondf_a,   # 1: no diff; 2: some diff
    visiondf_a %in% c(3, 4) ~ 3,            # 3: a lot of diff or cannot do at all
    visiondf_a %in% c(7, 8, 9) ~ NA
  ))

# Hearing
his24a <- his24a |>
  mutate(hearing = case_when(
    hearingdf_a %in% c(1, 2) ~ hearingdf_a,
    hearingdf_a %in% c(3, 4) ~ 3,
    hearingdf_a %in% c(7, 8, 9) ~ NA
  ))

# Communication
his24a <- his24a |>
  mutate(communication = case_when(
    comdiff_a %in% c(1, 2) ~ comdiff_a,
    comdiff_a %in% c(3, 4) ~ 3,
    comdiff_a %in% c(7, 8, 9) ~ NA
  ))

# Cognition
his24a <- his24a |>
  mutate(cognition = case_when(
    cogmemdff_a %in% c(1, 2) ~ cogmemdff_a,
    cogmemdff_a %in% c(3, 4) ~ 3,
    cogmemdff_a %in% c(7, 8, 9) ~ NA
  ))

# Self-Care
his24a <- his24a |>
  mutate(self_care = case_when(
    uppslfcr_a %in% c(1, 2) ~ uppslfcr_a,
    uppslfcr_a %in% c(3, 4) ~ 3,
    uppslfcr_a %in% c(7, 8, 9) ~ NA
  ))

# Mobility
his24a <- his24a |>
  mutate(mobility = case_when(
    diff_a %in% c(1, 2) ~ diff_a,
    diff_a %in% c(3, 4) ~ 3,
    diff_a %in% c(7, 8, 9) ~ NA
  ))

# 3-category disability indicator
his24a <- his24a |>
  mutate(dis3_indicator = case_when(
    vision == 3 | hearing == 3 | communication == 3 | cognition == 3 | self_care == 3 | mobility == 3 ~ 3,
    vision == 2 | hearing == 2 | communication == 2 | cognition == 2 | self_care == 2 | mobility == 2 ~ 2,
    vision == 1 | hearing == 1 | communication == 1 | cognition == 1 | self_care == 1 | mobility == 1 ~ 1,
    is.na(vision) & is.na(hearing) & is.na(communication) & is.na(cognition) & is.na(self_care) & is.na(mobility) ~ NA
  ))

# Create dummy variables for functioning variable
his24a <- his24a |>
  mutate(
    no_diff   = as.integer(dis3_indicator == 1),
    some_diff = as.integer(dis3_indicator == 2),
    alot_diff = as.integer(dis3_indicator == 3)
  )


###############################################################################
# Construct Other Variables Needed for Analysis ###############################
###############################################################################

# Sex
his24a <- his24a |>
  mutate(male = case_when(
    sex_a == 1 ~ 1,
    sex_a == 2 ~ 0,
    is.na(sex_a) ~ NA
  ))

# Age variable not missing / adult analytic sample flag
his24a <- his24a |>
  mutate(age18 = case_when(
    agep_a >= 18 & agep_a < 97 ~ 1,
    is.na(agep_a) | agep_a >= 97 ~ 0
  ))

###############################################################################
# Create Factor Variable Versions of Variables ###############################
###############################################################################

difflev_label <- c("No difficulty", "Some difficulty", "A lot of difficulty or cannot do at all")
his24a$dis3_indicatorf <- factor(his24a$dis3_indicator, levels = c(1, 2, 3), labels = difflev_label)

male_label <- c("Female", "Male")
his24a$malef <- factor(his24a$male, levels = c(0, 1), labels = male_label)

###

his24a <- his24a |>
  mutate(age_group_std = case_when(
    agep_a >= 18 & agep_a <= 44 ~ 1,      # 18-44
    agep_a >= 45 & agep_a <= 54 ~ 2,      # 45-54
    agep_a >= 55 & agep_a <= 64 ~ 3,      # 55-64
    agep_a >= 65 & agep_a <= 74 ~ 4,      # 65-74
    agep_a >= 75 & agep_a < 97  ~ 5,      # 75+
    agep_a >= 97 | is.na(agep_a) ~ NA
  ))

############
vars3 = c(
  "vision", "hearing", "communication", "cognition", "self_care", "mobility"
  , "dis3_indicator"
)

vars = c(
  # Survey design variables
  "ppsu", "pstrat", "wtfa_a"
  # Age indicator for subsetting
  , "age18"
  # Age group for age standardization
  , "age_group_std"
  # Outcome variables
  , vars3
  , "no_diff", "some_diff", "alot_diff"
  # Other variables
  # , "male"
  , "sex_a", "agep_a"
)

nhis2024_df = his24a[,vars]
nhis2024_df = nhis2024_df[which(nhis2024_df$age18 == 1),]
nhis2024_df %<>% as.data.frame()
nhis2024_df$age18 = NULL

for (ii in vars3) {
  nhis2024_df[,ii] %<>% factor(levels = 1:3, labels = c("No difficulty", "Some difficulty"
                                                        , "A lot of difficulty"))
}
for (ii in c("no_diff", "some_diff", "alot_diff")) {
  nhis2024_df[,ii] %<>% as.logical()
}
nhis2024_df$sex_a %<>% factor(levels = 1:2, labels = c("Male", "Female"))
nhis2024_df$age_group_std %<>% factor(levels = 1:5, labels = c(
  "18-44", "45-54", "55-64", "65-74", "75+"
))

attr(nhis2024_df$age_group_std, "label") = "Age group"
attr(nhis2024_df$vision, "label") = "Difficulty seeing"
attr(nhis2024_df$hearing, "label") = "Difficulty hearing"
attr(nhis2024_df$communication, "label") = "Difficulty communicating"
attr(nhis2024_df$cognition, "label") = "Difficulty with cognition"
attr(nhis2024_df$self_care, "label") = "Difficulty with self-care"
attr(nhis2024_df$mobility, "label") = "Difficulty with mobility"
attr(nhis2024_df$dis3_indicator, "label") = "Disability indicator"
attr(nhis2024_df$no_diff, "label") = "Disability: no difficulty"
attr(nhis2024_df$some_diff, "label") = "Disability: some difficulty"
attr(nhis2024_df$alot_diff, "label") = "Disability: a lot of difficulty"
attr(nhis2024_df$sex_a, "label") = "Sex of Sample Adult"
attr(nhis2024_df$agep_a, "label") = "Age of Sample Adult (top coded)"

nhis2024a = svydesign(
  data    = nhis2024_df,
  ids      = ~ppsu,
  strata  = ~pstrat,
  weights = ~wtfa_a,
  nest    = TRUE
)
attr(nhis2024a, "label") = "NHIS 2024 PUF (Adults)"
# his24_svy_samp
# analytic sample: adults age 18+

usethis::use_data(nhis2024a, overwrite = TRUE)
