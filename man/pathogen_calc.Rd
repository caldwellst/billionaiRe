% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hep.R
\name{pathogen_calc}
\alias{pathogen_calc}
\title{Calculate the vaccine coverage for a specific pathogen}
\usage{
pathogen_calc(
  df,
  name,
  ind,
  iso3,
  year,
  numerators,
  denominators,
  transform_value,
  type,
  ind_ids,
  multiply_surviving_infs = TRUE
)
}
\arguments{
\item{df}{Data frame in long format, where 1 row corresponds to a specific
country, year, and indicator.}

\item{name}{Name of pathogen to provide in the data frame.}

\item{ind}{Column name of column with indicator names.}

\item{iso3}{Column name of column with country ISO3 codes.}

\item{year}{Column name of column with year data.}

\item{numerators}{Indicator names for numerators.}

\item{denominators}{Indicator names for denominators.}

\item{transform_value}{Column name of column with transformed values.}

\item{type}{Column name of column with type data.}

\item{ind_ids}{Named vector of indicator codes for input indicators to the Billion.
Although separate indicator codes can be used than the standard, they must
be supplied as a named vector where the names correspond to the output of
\code{billion_ind_codes()}.}

\item{multiply_surviving_infs}{Logical, multiple surviving infant population by
number of routine vaccines in numerator.}
}
\description{
Using numerators and denominators pre-supplied for each ISO3 and year,
the overall vaccine coverage for a pathogen is calculated. This function
currently counts the number of routine vaccinations included in the numerator,
and multiplies the surviving infants denominator by that number.
}
\details{
This function is currently called from the \code{prevent_calculations()} function
that sits within \code{calculate_hep_components()}.
}
