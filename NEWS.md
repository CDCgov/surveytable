# surveytable (development version)

* More `set_opts(output = *)` options: `"Word"`, `"Excel"`, `"Excel_v1"`, `"flextable"`.

# surveytable 0.9.10

* Resolved issues affecting printing.

# surveytable 0.9.9

* `set_opts(output = "raw")`: unformatted / raw output. This is useful for getting lots of significant digits.
* Simplified confidence interval for proportions adjustment: `adj` argument to `set_opts()` and `svyciprop_adjusted()`.
* Show the test statistic for all tests.
* Conditional independence test: `tab_subset()` with argument `test` set to the 
value of interest. 
* Confidence intervals for numeric variables. 
* Excel tables and charts! `set_opts( output = "excel", file = "my_workbook" )`
* Improved conversion of tables to data frames with `as.data.frame()`.
* The interface for CSV printing is now the same as for all other kinds of printing: `set_opts( output = "CSV", file = "my_file" )`

# surveytable 0.9.8

* Optionally, show the test statistic, control rounding of the p-value.
* Improved handling of missing values and the `drop_na` argument in `tab_subset()` and `tab_subset_rate()`.
* Improved handling of `character` variables.
* Improved handling of Spark-based (`sparklyr`) survey objects.

# surveytable 0.9.7

* Bugfixes.

# surveytable 0.9.6

* Ability to customize how the tables are printed.
  * `output` argument to `set_opts()`
  * More details in `help("surveytable-options")`
* Ability to customize rounding.
  * More details in `help("surveytable-options")`

# surveytable 0.9.5

* Another public use data file for use in examples: `rccsu2018`.
* `set_opts()` replaces several other functions for setting options.

# surveytable 0.9.4

* Optionally adjust p-values for multiple comparisons (`p_adjust` argument).

# surveytable 0.9.3

* `codebook()`
* `set_survey()`:
  * Improved output.
  * Allows an unweighted survey as a `data.frame`.
  * Can set certain options using an argument.
* Tabulation functions show the number of observations.
* PDF / LaTeX printing.

# surveytable 0.9.2

* Addressed CRAN comments.

# surveytable 0.9.1

* Initial CRAN submission.
