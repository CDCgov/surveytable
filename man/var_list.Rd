% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/var_list.R
\name{var_list}
\alias{var_list}
\title{List variables in a survey.}
\usage{
var_list(sw = "", all = FALSE, csv = getOption("surveytable.csv"))
}
\arguments{
\item{sw}{starting characters in variable name (case insensitive)}

\item{all}{print all variables?}

\item{csv}{name of a CSV file}
}
\value{
A table
}
\description{
List variables in a survey.
}
\examples{
set_survey(namcs2019sv)
var_list("age")
}
