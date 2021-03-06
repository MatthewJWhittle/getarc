% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utility_functions.R
\name{as_type}
\alias{as_type}
\title{As Type}
\usage{
as_type(x, type)
}
\arguments{
\item{x}{a vector}

\item{type}{the type to convert the vector to}
}
\value{
a vector of with the values of \code{x} and the same type as \code{type}
}
\description{
Convert a vector to a specific type
}
\details{
This function is used to convert a vector to a specific type, for instance where variables need to match types in joins.
}
