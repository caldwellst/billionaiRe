% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wrangle_data.R
\name{wrangle_unsd_data}
\alias{wrangle_unsd_data}
\title{Put UNSD data into billionaiRe format}
\usage{
wrangle_unsd_data(df, source = NULL, type = NULL)
}
\arguments{
\item{df}{A data frame in UNSD format, returned from \code{\link[goalie:sdg_data]{goalie::sdg_data()}}.}

\item{source}{Character string of source to be provided to the data frame if
the source is not already available in the UNSD database. If \code{NULL},
the source column is generated from the UNSD's \code{Source} column.}

\item{type}{Character string of type to be provided to the data frame. If
\code{NULL}, the type column is generated from the UNSD's \code{Nature} column.
"C" and "CA" are turned to "reported", while "E" and "M" are "estimated".}
}
\value{
A data frame.
}
\description{
\code{wrangle_gho_data()} takes data returned from the UNSD API, which should
be obtained using \code{\link[goalie:sdg_data]{goalie::sdg_data()}}, and transforms it into data that is
ready to be put into the xMart database and used within the billionaiRe
package. Currently, providing source and type inputs these values into the
entire data frame, so does not work if multiple indicators have been loaded
into the SDG data frame. As well, the UNSD series code is kept in the data
frame until \code{indicators_df} contains UNSD codes and can convert between the
two.
}
