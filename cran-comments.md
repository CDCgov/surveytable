## R CMD check results

0 errors ✔ | 0 warnings ✔ | 3 notes ✖

Duration: 2m 16.3s

❯ checking CRAN incoming feasibility ... [24s] NOTE
  Maintainer: 'Alex Strashny <alex.strashny@gmail.com>'
  
  Found the following (possibly) invalid DOIs:
    DOI: 10.15620/cdc:124368
      From: DESCRIPTION
            man/surveytable-package.Rd
      Status: Error
      Message: libcurl error code 35:
      	schannel: next InitializeSecurityContext failed: CRYPT_E_NO_REVOCATION_CHECK (0x80092012) - The revocation function was unable to check revocation for the certificate.
    DOI: 10.18637/jss.v009.i08
      From: DESCRIPTION
            man/surveytable-package.Rd
      Status: Error
      Message: libcurl error code 35:
      	schannel: next InitializeSecurityContext failed: CRYPT_E_NO_REVOCATION_CHECK (0x80092012) - The revocation function was unable to check revocation for the certificate.
    DOI: 10.32614/CRAN.package.surveytable
      From: inst/CITATION
      Status: Error
      Message: libcurl error code 35:
      	schannel: next InitializeSecurityContext failed: CRYPT_E_NO_REVOCATION_CHECK (0x80092012) - The revocation function was unable to check revocation for the certificate.
      	
      	
* These are valid DOIs. 
* DOI: 10.15620/cdc:124368
  * https://stacks.cdc.gov/view/cdc/124368
* DOI: 10.18637/jss.v009.i08
  * https://www.jstatsoft.org/article/view/v009i08
* DOI: 10.32614/CRAN.package.surveytable
	* https://cran.r-project.org/package=surveytable


❯ checking for future file timestamps ... NOTE
  unable to verify current time

❯ checking sizes of PDF files under 'inst/doc' ... NOTE
  Unable to find GhostScript executable to run checks on size reduction

## Response

The flagged DOIs are valid.

