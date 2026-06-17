uspop_example = list(total = 323186697, MSA = structure(list(Level = c("MSA (Metropolitan Statistical Area)",
"Non-MSA"), Population = c(277229518, 45957179)), row.names = c(NA,
-2L), class = "data.frame"), AGER = structure(list(Level = c("Under 15 years",
"15-24 years", "25-44 years", "45-64 years", "65-74 years", "75 years and over"
), Population = c(60526656, 41718700, 85599410, 82562049, 31260202,
21519680)), row.names = c(NA, -6L), class = "data.frame"), `Age group` = structure(list(
    Level = c("Under 1", "1-4", "5-14", "15-64", "65 and over"
    ), Population = c(3781275, 15789965, 40955416, NA, 52779882
    )), row.names = c(NA, -5L), class = "data.frame"), SEX = structure(list(
    Level = c("Female", "Male"), Population = c(165130608, 158056089
    )), row.names = c(NA, -2L), class = "data.frame"), `AGER x SEX` = structure(list(
    Level = c("Under 15 years", "15-24 years", "25-44 years",
    "45-64 years", "65-74 years", "75 years and over", "Under 15 years",
    "15-24 years", "25-44 years", "45-64 years", "65-74 years",
    "75 years and over"), Subset = c("Female", "Female", "Female",
    "Female", "Female", "Female", "Male", "Male", "Male", "Male",
    "Male", "Male"), Population = c(29604762, 20730118, 43192143,
    42508901, 16673240, 12421444, 30921894, 20988582, 42407267,
    40053148, 14586962, 9098236)), row.names = c(NA, -12L), class = "data.frame"),
    `Age group 5` = structure(list(Level = c("Under 1", "1-17",
    "18-44", "45-64", "65 and over"), Population = c(3781275,
    69118503, 114944988, 82562049, 52779882)), row.names = c(NA,
    -5L), class = "data.frame"))

uspop_example$age_group_std = data.frame(
  Level = c("18-44", "45-54", "55-64", "65-74", "75+")
  , Population = c(108151050, 37030152, 23961506, 18135514, 16573966)
)

uspop_example$age_group_std_prop = uspop_example$age_group_std
uspop_example$age_group_std_prop$Population = uspop_example$age_group_std_prop$Population / sum(uspop_example$age_group_std_prop$Population)

usethis::use_data(uspop_example, overwrite = TRUE)
