## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Responses to comments

If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file in the form authors (year) <doi:...> authors (year) <arXiv:...> authors (year, ISBN:...) or if those are not available: <https:...> with no space after 'doi:', 'arXiv:', 'https:' and angle brackets for auto-linking. (If you want to add a title as well please put it in
quotes: "Title")

* DONE. Added references to 1 package and 3 papers.

\dontrun{} should only be used if the example really cannot be executed (e.g. because of missing additional software, missing API keys, ...) by the user. That's why wrapping examples in \dontrun{} adds the comment ("# Not run:") as a warning for the user. Does not seem necessary.
Please replace \dontrun with \donttest.
Please unwrap the examples if they are executable in < 5 sec, or replace dontrun{} with \donttest{}.
-> set_output.Rd; survey_subset.Rd

* DONE. Removed dontrun.

You write information messages to the console that cannot be easily suppressed.
It is more R like to generate objects that can be used to extract the information a user is interested in, and then print() that object.
Instead of print()/cat() rather use message()/warning() or
if(verbose)cat(..) (or maybe stop()) if you really have to write text to the console. (except for print, summary, interactive functions) -> R/set_survey.R; R/z_write_out.R

* set_survey.R: DONE. The function now returns an object.
* z_write_out.R: DONE. .write_out() now does not print anything. The functions that call .write_out() now return an object. R/print.surveytable_table.R now has the print functions for these objects.

Please ensure that your functions do not write by default or in your examples/vignettes/tests in the user's home filespace (including the package directory and getwd()). This is not allowed by CRAN policies.
Please omit any default path in writing functions. In your examples/vignettes/tests you can write to tempdir(). -> R/z_write_out.R

* DONE. In examples for set_output() and in vignettes, now using tempfile().

Please also use on.exit() to reset the options in R/z_write_out.R (line 31).

* DONE. Now in R/print.surveytable_table.R (line 45).

Please do not modifiy the .GlobalEnv. This is not allowed by the CRAN policies. -> R/zzz.R

* DONE. The package no longer modifies .GlobalEnv.
