% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_access.R
\name{billion_ind_codes}
\alias{billion_ind_codes}
\title{Indicator codes for the Billions}
\usage{
billion_ind_codes(billion = c("hep", "hpop", "uhc"))
}
\arguments{
\item{billion}{Billion indicator names to return, either "hep", "hpop", or "uhc".}
}
\value{
Character vector of indicator names.
}
\description{
Provides analysis codes required for input into the Triple Billion calculations.
The named vector returned by the function is the default names assumed to be
in any data frame passed to calculate Billions.
}
