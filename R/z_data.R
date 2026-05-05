#' National Health Interview Survey (NHIS) 2024 Public Use File (PUF)
#'
#' NHIS is a national survey that monitors the health of the U.S. population. This
#' survey object contains selected variables and is limited to observations on
#' individuals aged 18+ only.
#'
#' @source
#' * Data ("Sample adult interview"): <https://www.cdc.gov/nchs/nhis/documentation/2024-nhis.html>
"nhis2024a"

#' Selected variables from the National Ambulatory Medical Care Survey (NAMCS) 2019 Public Use File (PUF)
#'
#' Selected variables from a data system of visits to office-based physicians.
#' Note that the unit of observation is visits, not patients - this distinction
#' is important since a single patient can make multiple visits.
#'
#' `namcs2019sv_df` is a data frame.
#'
#' `namcs2019sv` is a survey object created from `namcs2019sv_df`
#' using `survey::svydesign()`.
#'
#' @source
#' * SAS data: <https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NAMCS/sas/namcs2019_sas.zip>
#' * Survey design variables: <https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NAMCS/sas/readme2019-sas.txt>
#' * SAS formats: <https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NAMCS/sas/nam19for.txt>
#' * Documentation: <https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NAMCS/doc2019-508.pdf>
#' * National Summary Tables: <https://www.cdc.gov/nchs/data/ahcd/namcs_summary/2019-namcs-web-tables-508.pdf>
"namcs2019sv"

#' @rdname namcs2019sv
"namcs2019sv_df"

#' US Population for use in examples
#'
#' Population counts for use in examples.
#'
#' Most of the list elements are population estimates of the civilian non-institutional
#' population of the United States as of July 1, 2019. Used for calculating rates
#' based on [`namcs2019sv`]. For usage examples, see [`tab_rate()`] and
#' [`tab_subset_rate()`].
#'
#' `$age_group_std` is population counts for adults aged 18 and older, by age
#' group, from the 2000 US Standard Population as published by the U.S. Census
#' Bureau. Used as the reference population for age-standardization of survey
#' estimates based on [`nhis2024a`]. For usage examples, see [`set_survey()`].
#'
#' @examples
#' names(uspop_example)
"uspop_example"

#' National Study of Long-Term Care Providers (NSLTCP) Residential Care Community (RCC) Services User (SU) 2018 Public Use File (PUF)
#'
#' A data system of RCC residents.
#'
#' @source
#' * SAS data: <https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NPALS/>
#' * Documentation: <https://www.cdc.gov/nchs/npals/RCCresident-readme03152021vr.pdf>
#' * Codebook: <https://www.cdc.gov/nchs/data/npals/final2018rcc_su_puf_codebook.pdf>
"rccsu2018"
