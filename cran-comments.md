## R CMD check results

0 errors ✔ | 0 warnings ✔ | 2 notes ✖

Duration: 2m 29.5s

❯ checking CRAN incoming feasibility ... [20s] NOTE
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

❯ checking sizes of PDF files under 'inst/doc' ... NOTE
  Unable to find GhostScript executable to run checks on size reduction


## Response

The flagged DOIs are valid.

