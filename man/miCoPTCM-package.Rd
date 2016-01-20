\name{miCoPTCM-package}
\alias{miCoPTCM-package}
\alias{miCoPTCM}
\docType{package}
\title{
Promotion Time Cure Model with Mis-Measured Covariates
}
\description{
Fits Semiparametric Promotion Time Cure Models, taking into account (using a corrected score approach 
or the SIMEX algorithm) or not the measurement error in the covariates, using a backfitting 
approach to maximize the likelihood.
}
\details{

\packageDESCRIPTION{miCoPTCM}
\packageIndices{miCoPTCM}


The survival model of interest is the promotion time cure model, i.e. a survival model which takes into account the existence of subjects who will never experience the event. The survival function of \eqn{T}, the survival time, is assumed to be improper:
\deqn{S(t|\bm{x}) = P(T>t|\bm{X}=\bm{x}) = \exp\left\{-\theta(\bm{x}) F(t) \right\},}
where \eqn{F} is a proper baseline cumulative distribution function, \eqn{\theta} is a link function with an intercept, here \eqn{\theta(\bm{x}) = \exp(\bm{x}^T \bm{\beta})}, and \eqn{\bm{x}} is the vector of covariates. We work with the semiparametric version of this model, in which no known distribution is assumed for \eqn{F}.
It can be shown that the nonparametric estimator of \eqn{F} is a step function which increases only at the failure times. 

We assume that we have right censoring in our data, so that \eqn{Y=\min(T,C)} is observed, where \eqn{C} is the censoring time.

The classical additive error model is assumed for the covariates, so that \eqn{\bm{W}=\bm{X}+\bm{U}} is observed,  where \eqn{\bm{W}} is the vector of observed covariates and \eqn{\bm{U}} is the vector of measurement errors. We  assume that \eqn{\bm{U}} is independent of \eqn{\bm{X}} and \eqn{\bm{U}} follows a continuous distribution with mean zero and known covariance matrix \eqn{\bm{V}}. It is also assumed that \eqn{(T,C)} and \eqn{\bm{W}} are independent given \eqn{\bm{X}}.

Three possible estimation methods are available in this package. The corrected score approach of Ma and Yin (2008) is implemented in function \code{PTCMestimBF}. It consists in solving, through a backfitting procedure, the score equations in which the terms involving \eqn{\bm{x}} are replaced by some terms involving \eqn{\bm{w}} and \eqn{\bm{V}}. 
The naive method consists in not taking the measurement error in the covariates into account. The naive estimate is obtained by using function \code{PTCMestimBF} with a variance-covariance matrix of the error containing only zeros.
Finally, the SIMEX algorithm applied to the promotion time cure model (Bertrand et al., 2015) is implemented in the function \code{PTCMestimSIMEX}. The SIMEX algorithm (Cook and Stefanski, 1994) is a generic and intuitive procedure allowing to estimate and reduce the bias in a model in which the covariates are measured with error. In this implementation, the naive estimator required by the procedure is the one of Ma and Yin (2008).

}
\author{
Aurelie Bertrand, Catherine Legrand, Ingrid Van Keilegom

Maintainer: Aurelie Bertrand <aurelie.bertrand@uclouvain.be>
}
\references{
Bertrand A., Legrand C., Carroll R.J., De Meester C., Van Keilegom I. (2015) Inference in a Survival Cure Model with Mismeasured Covariates using a SIMEX Approach. Submitted.

Cook J.R., Stefanski L.A. (1994) Simulation-Extrapolation Estimation in Parametric Measurement Error Models. Journal of the American Statistical Association, 89, 1314-1328. DOI: 10.2307/2290994

Ma, Y., Yin, G. (2008) Cure rate models with mismeasured covariates under transformation. Journal of the American Statistical Association, 103, 743-756. DOI: 10.1198/016214508000000319
}


