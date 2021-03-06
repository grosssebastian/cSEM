% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helper_infer.R, R/postestimate_infer.R
\name{MeanResample}
\alias{MeanResample}
\alias{SdResample}
\alias{BiasResample}
\alias{StandardCIResample}
\alias{PercentilCIResample}
\alias{BasicCIResample}
\alias{TStatCIResample}
\alias{BcCIResample}
\alias{BcaCIResample}
\alias{infer}
\title{Inference}
\usage{
MeanResample(.first_resample)

SdResample(.first_resample, .resample_method, .n)

BiasResample(.first_resample, .resample_method, .n)

StandardCIResample(.first_resample, .bias_corrected, .dist = c("z", "t"),
  .df = c("type1", "type2"), .resample_method, .n, .probs)

PercentilCIResample(.first_resample, .probs)

BasicCIResample(.first_resample, .bias_corrected, .probs)

TStatCIResample(.first_resample, .second_resample, .bias_corrected,
  .resample_method, .resample_method2, .n, .probs)

BcCIResample(.first_resample, .probs)

BcaCIResample(.object, .first_resample, .probs)

infer(
 .object            = NULL,
 .alpha             = 0.05,
 .bias_corrected    = TRUE,
 .quantity          = c("all", "mean", "sd", "bias", "CI_standard_z", 
                        "CI_standard_t", "CI_percentile", "CI_basic", 
                        "CI_bc", "CI_bca", "CI_t_interval")
)
}
\arguments{
\item{.first_resample}{A list containing the \code{.R} resamples based on the original
data obtained by resamplecSEMResults().}

\item{.resample_method}{Character string. The resampling method to use. One of:
"\emph{none}", "\emph{bootstrap}" or "\emph{jackknife}". Defaults to "\emph{none}".}

\item{.n}{Integer. The number of observations of the original data.}

\item{.bias_corrected}{Logical. Should the standard and the tStat
confidence intervall be bias-corrected using the bootstraped bias estimate?
If \code{TRUE} the confidence intervall for some estimated parameter \code{theta}
is centered at \code{2*theta - theta*_hat},
where \code{theta*_hat} is the average over all .R bootstrap estimates of \code{theta}.
Defaults to \code{TRUE}}

\item{.dist}{Character string. The distribution to use for the critical value.
One of \emph{"t"} for Student's t-distribution or \emph{"z"} for the standard normal distribution.
Defaults to \emph{"z"}.}

\item{.df}{Character string. The method for obtaining the degrees of freedom.
Choices are "\emph{type1}" and "\emph{type2}". Defaults to "\emph{type1}" .}

\item{.probs}{A vector of probabilities.}

\item{.second_resample}{A list containing \code{.R2} resamples for each of the \code{.R}
resamples of the first run.}

\item{.resample_method2}{Character string. The resampling method to use when resampling
from a resample. One of: "\emph{none}", "\emph{bootstrap}" or "\emph{jackknife}". For
"\emph{bootstrap}" the number of draws is provided via \code{.R2}. Currently,
resampling from each resample is only required for the studentized confidence
intervall computed by the \code{\link[=infer]{infer()}} function. Defaults to "\emph{none}".}

\item{.object}{An R object of class \link{cSEMResults} resulting from a call to \code{\link[=csem]{csem()}}.}

\item{.alpha}{An integer or a numeric vector of significance levels.
Defaults to \code{0.05}.}

\item{.quantity}{Character string. Which statistic should be returned?
One of (TODO)
Defaults to (TODO).}
}
\description{
Calculate common inferencial quantities (e.g., estimated standard error, estimated bias,
several confidence intervals) based on a \code{cSEMResults_resampled} object as obtained
by calling \code{\link[=resamplecSEMResults]{resamplecSEMResults()}} or by setting \code{.resample_method = "bootstrap"}
or \code{"jackknife"} when calling \code{\link[=csem]{csem()}}. Currently, the following quantities are
returned by default (\code{.quantity = "all"}):
\describe{
\item{\code{"mean"}, \code{"sd"} and \code{"bias"}}{The mean, the standard
deviation and the bias (defined as the difference between the resample mean
and the original estimate).}
\item{\code{"CI_standard_z"} and \code{"CI_standard_t"}}{The standard confidence interval
with standard errors estimated by the resample standard deviation.
While \code{"CI_standard_z"} assumes a standard-normally distributed statistic,
\code{"CI_standard_t"} assumes a t-statistic with \code{.df = c("type1", "type2")}}
\item{\code{"CI_percentile"}}{The percentile confidence interval}
\item{\code{"CI_basic"}}{The basic confidence interval}
\item{\code{"CI_bc"}}{The bias corrected confidence interval}
}
}
\details{
In addtion, the bias-corrected and accelerated (\code{"CI_bca"}) and/or the "studentized"
confidence interval (\code{"CI_t_interval"}) can be returned. The former requires jackknife estimates
to compute influence values and the latter requires double bootstrap
both take time. Hence, the will only be computed if explicitly given.
}
\section{Functions}{
\itemize{
\item \code{MeanResample}: Computes the mean over all resamples for each resampled
statistic/parameter.

\item \code{SdResample}: Computes the standard deviation over all resamples for each resampled
statistic/estimator This is usually taken to be the estimate
of the standard error of the statistic/estimator.

\item \code{BiasResample}: Computes the estimated bias for each resampled
statistic/estimator.

\item \code{StandardCIResample}: Computes the \emph{Standard CI with bootstrap SE's}.
Critical quantiles can be based on both the \code{t}- or the
standard normal distribution (\code{z}). The former may perform better in
small samples but there is no clear consenus on what the degrees of freedom
should be.

\item \code{PercentilCIResample}: Computes the \emph{Percentile CI}.
The function takes the distribution F* (the CDF) of the resamples as an estimator for
the true distribution F of the statistic/estimator of interest.
Quantiles of the estimated distribution are then used as lower and upper bound.

\item \code{BasicCIResample}: Computes the \emph{Basic CI}.

\item \code{TStatCIResample}: Computes the \emph{Studentized or t-statistic CI}
The function computes a boostrap t-statisic (since it is roughly pivotal) and constructs
the CI based on bootstraped t-values and bootstraped/jackknife SE's

\item \code{BcCIResample}: (TODO)

\item \code{BcaCIResample}: (TODO)
}}

\examples{
\dontrun{
# still to implement
}

}
\seealso{
\code{\link[=csem]{csem()}}, \code{\link[=resamplecSEMResults]{resamplecSEMResults()}}, \link{cSEMResults}
}
