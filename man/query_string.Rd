% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_string.R
\name{query_string}
\alias{query_string}
\title{Query String}
\usage{
query_string(f = "json", my_token = NULL, ...)
}
\arguments{
\item{f}{return format "json by default}

\item{my_token}{An access token to be included in the string if specified}

\item{...}{additional query parameters passed as named pairs. Names are the parameter names and the values are the parameter values. For example: list(outFields = "*")}
}
\value{
a string, beginning with "query?" to concatenate with the end point
}
\description{
Generate a query string to combine with the endpoint
}
\details{
This function accepts a named list or vector of query parameters. It compares the
parameters with standard parameters and returns a string.
}
