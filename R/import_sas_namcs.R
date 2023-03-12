#' Import SAS data into R, with survey design variables the same as those in NAMCS 2019 PUF.
#'
#' @param sas_data  SAS survey data file
#' @param sas_formats_data    SAS formats data file (produced with `PROC FORMAT` with the `CNTLOUT` option)
#' @param r_out   name of a new R data file
#'
#' @return (Nothing.)
#' @family import
#' @export
#'
#' @examples
#' \dontrun{
#' import_sas_namcs2019puf(
#' sas_data = "namcs2019_sas.sas7bdat"
#' , sas_formats_data = "formats_dataset.sas7bdat"
#' , r_out = "namcs_2019_puf.rds")
#' }
import_sas_namcs2019puf = function(sas_data, sas_formats_data, r_out) {
  assert_that(!file.exists(r_out)
              , msg = paste0("Output file ", r_out, " already exists."))

  options(prettysurvey.import.bool_levels = c("yes", "no")
    , prettysurvey.import.bool_true = "yes"
    , prettysurvey.import.bool_false = "no"
  )
	d1 = import_sas(sas_data, sas_formats_data, formats = "attr")

	sdo = svydesign(ids = ~ CPSUM
		, strata = ~ CSTRATM
		, weights = ~ PATWT
		, data = d1)

	message("\n*** Please verify that the correct survey design variables are used (ids, strata, weights): ")
	message(sdo)

	saveRDS(sdo, r_out)
}
