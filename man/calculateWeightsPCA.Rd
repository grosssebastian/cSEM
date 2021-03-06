% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/estimators_weights.R
\name{calculateWeightsPCA}
\alias{calculateWeightsPCA}
\title{Calculate composite weights using principal component analysis (PCA)}
\usage{
calculateWeightsPCA(
 .S                 = args_default()$.S,
 .csem_model        = args_default()$.csem_model
  )
}
\arguments{
\item{.S}{The (K x K) empirical indicator correlation matrix.}

\item{.csem_model}{A (possibly incomplete) \link{cSEMModel}-list.}
}
\value{
A list with the elements
\describe{
\item{\code{$W}}{A (J x K) matrix of estimated weights.}
\item{\code{$E}}{A (J x J) matrix of inner weights.}
\item{\code{$Modes}}{A named vector of modes used for the outer estimation.}
\item{\code{$Conv_status}}{The convergence status. \code{TRUE} if the algorithm has converged
and \code{FALSE} otherwise. If one-step weights are used via \code{.iter_max = 1}
or a non-iterative procedure was used, the convergence status is set to \code{NULL}.}
\item{\code{$Iterations}}{The number of iterations used.}
}
}
\description{
Calculate weights for each block by extracting the first principal component
of the indicator correlation matrix S_jj for each blocks, i.e., weights
are the simply the first eigenvector of S_jj.
}
