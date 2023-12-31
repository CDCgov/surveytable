% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/set_output.R
\name{set_output}
\alias{set_output}
\alias{show_output}
\title{Set output defaults}
\usage{
set_output(csv = NULL, screen = NULL, max_levels = NULL)

show_output()
}
\arguments{
\item{csv}{name of a CSV file or "" to turn off CSV output}

\item{screen}{print to the screen?}

\item{max_levels}{a categorical variable can have at most this many levels. Used to avoid printing huge tables.}
}
\value{
(Nothing.)
}
\description{
\code{show_output()} shows the current defaults.
}
\examples{
\dontrun{
set_output(csv = "out.csv")
show_output()
}
set_output(csv = "") # Turn off CSV output
}
\seealso{
Other options: 
\code{\link{set_count_1k}()},
\code{\link{set_survey}()},
\code{\link{show_options}()},
\code{\link{surveytable-options}}
}
\concept{options}
