% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/var_cross.R
\name{var_cross}
\alias{var_cross}
\title{Cross or interact two variables}
\usage{
var_cross(newvr, vr, vrby)
}
\arguments{
\item{newvr}{name of the new variable to be created}

\item{vr}{first variable}

\item{vrby}{second variable}
}
\value{
Survey object
}
\description{
Create a new variable which is an interaction of two other variables. Also
see \code{\link[=tab_cross]{tab_cross()}}.
}
\examples{
set_survey(namcs2019sv)
var_cross("Age x Sex", "AGER", "SEX")
tab("Age x Sex")
}
\seealso{
Other variables: 
\code{\link{var_all}()},
\code{\link{var_any}()},
\code{\link{var_case}()},
\code{\link{var_collapse}()},
\code{\link{var_copy}()},
\code{\link{var_cut}()},
\code{\link{var_not}()}
}
\concept{variables}
