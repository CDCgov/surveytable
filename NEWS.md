# surveytable (development version)

* Optionally, show the test statistic, control rounding of the p-value.
* Improved handling of missing values and the `drop_na` argument in `tab_subset()` and `tab_subset_rate()`.
* Improved handling of `character` variables.
* Improved handling of Spark-based (`sparklyr`) survey objects.

# surveytable 0.9.7

* Bugfixes.

# surveytable 0.9.6

* Ability to customize how the tables are printed.
  * `output` argument to `set_opts()`
  * New function: `as_object()`
  * More details in `help("surveytable-options")`
* Ability to customize rounding.
  * More details in `help("surveytable-options")`

# surveytable 0.9.5

* Another public use data file for use in examples: `rccsu2018`.
* `set_opts()` replaces several other functions for setting options.

# surveytable 0.9.4

* Optionally adjust p-values for multiple comparisons (`p_adjust` argument)

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
