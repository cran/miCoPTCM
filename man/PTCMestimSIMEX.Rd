\name{PTCMestimSIMEX}
\alias{PTCMestimSIMEX}
\alias{PTCMestimSIMEX.default}
\alias{PTCMestimSIMEX.formula}
\alias{print.PTCMestimSIMEX}
\alias{summary.PTCMestimSIMEX}
\alias{print.summary.PTCMestimSIMEX}

%- Also NEED an '\alias' for EACH other topic documented here.
\title{
SIMEX approach
}
\description{
Fits a Semiparametric Promotion Time Cure Model with mismeasured covariates, using the SIMEX algorithm based on a backfitting procedure. This approach is introduced in Bertrand et al. (2015).
}
\usage{
\method{PTCMestimSIMEX}{default}(x, y, errorDistEstim=c("normal","student","chiSquare","laplace"), 
paramDistEstim=NA, varCov=NA,  nBack=10000, eps=1e-8, Nu=c(0,.5,1,1.5,2), B=50, init, 
orderExtrap=2, multMaxTime=2,...)
\method{PTCMestimSIMEX}{formula}(formula, data=list(),...)
\method{print}{PTCMestimSIMEX}(x,...)
\method{summary}{PTCMestimSIMEX}(object,...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{ a numerical matrix containing the explanatory variables as columns (without a column of 1s for the intercept).}
  \item{y}{ the response, a survival object returned by the \code{Surv} function. }
  \item{errorDistEstim}{ the distribution of the measurement error. See Details.}
  \item{paramDistEstim}{ a scalar or a vector of length 2 containing the parameter(s) of the measurement error distribution, for non-Gaussian distributions. See Details.}
  \item{varCov}{ the square variance-covariance matrix of measurement error, with as many rows as regression parameters (including the intercept), for Gaussian errors.}
  \item{nBack}{ an integer specifying the maximal number of iterations in the backfitting procedure. }
  \item{eps}{ convergence criterion.  }
  \item{Nu}{ a numerical vector containing the grid of lambda values, corresponding to the level of added noise.}
  \item{B}{ the number of replications for each value in \code{Nu}.}
  \item{init}{a numerical vector of initial values for the regression parameters.}
  \item{orderExtrap}{ a scalar or a numerical vector containing the degrees of the polynomials used in the extrapolation step.}
  \item{multMaxTime}{ a positive number controlling the time allowed, in one iteration of the backfitting procedure, to function \code{nleqslv} (used to solve the score equations) to converge.  }
  \item{formula}{a formula object, in which the response is a survival object returned by the \code{Surv} function.}
  \item{data}{a dataframe containing the variables appearing in the model.}
  \item{object}{ an object of class \code{"PTCMestimBF"}, i.e., a fitted model.}
  \item{\dots}{ not used. }
}
\details{
More than one covariate can be subject to measurement error. However, in this implementation, all the errors must belong to the same family of distribution (specified with the argument \code{errorDistEstim}). Non-zero covariances are allowed between errors following a normal distribution. For the student, chi-squared and Laplace distributions, all variances are assumed to be equal (determined from \code{paramDistEstim}) and all covariances are assumed to be 0, even if the off-diagonal elements of \code{vcov} are not 0.

When using the \code{laplace} distribution, only one element in \code{paramDistEstim} is needed (if a vector of two elements is given, only the first element will be considered). With the \code{student} and \code{chiSquare} distributions, two parameters are required, while none is required with the \code{normal} distribution. 
For the \code{laplace} distribution, the parameter is the inverse of the rate \eqn{\gamma}, where \eqn{\gamma} is such that \eqn{f(x)=\frac{1}{2}\gamma e^{-\gamma |x|}}. The first parameter of the Student distribution corresponds to the degrees of freedom, while the second parameter is a multiplicative factor such that the variance is \eqn{parameter_2^2*\frac{parameter_1}{parameter_1-2}}. Similarly, for the chi-squared distribution, the first parameter gives the degrees of freedom, and the second one is a multiplicative factor yielding a variance of \eqn{2\cdot param_2^2 \cdot param_1}.


}
\value{
An object of class \code{PTCMestimBF}, i.e. a list including the following elements:
	\item{coefficients }{The estimated values of the regression parameters.}
	\item{var}{The estimated variances of the estimated regression parameters.}
	\item{classObs}{An integer vector of length 3: the number of censored individuals not considered as cured for the estimation, the number of events, and the number of individuals considered as cured for the estimation.}
	\item{estimNuBF}{A matrix with as many rows as elements in \code{Nu}, containing, in each row, the average of the \code{B} estimates, for each regression parameter (columns).}
}
\references{
Bertrand A., Legrand C., Carroll R.J., De Meester C., Van Keilegom I. (2015) Inference in a Survival Cure Model with Mismeasured Covariates using a SIMEX Approach. Submitted.

Cook J.R., Stefanski L.A. (1994) Simulation-Extrapolation Estimation in Parametric Measurement Error Models. Journal of the American Statistical Association, 89, 1314-1328. DOI: 10.2307/2290994

Ma, Y., Yin, G. (2008) Cure rate models with mismeasured covariates under transformation. Journal of the American Statistical Association, 103, 743-756. DOI: 10.1198/016214508000000319
}



\examples{
\dontrun{
library("survival")
## Data generation
set.seed(123)
n <- 200
varCov <- matrix(nrow=3,ncol=3,0)
varCov[2,2] <- 0.1^1
X1 <- (runif(n)-.5)/sqrt(1/12) 
V <- round(X1 + rnorm(n,rep(0,3),varCov[2,2]),7)# covariate with measurement error
Xc <- round(as.numeric(runif(n)<0.5),7) # covariate without measurement error

 # censoring times: truncated exponential distribution
C <- round(rexp(n,1/5),5) 
Cbin <- (C>30)
while(sum(Cbin)>0)
{
	C[Cbin] <- round(rexp(sum(Cbin),1/5),5)
	Cbin <- (C>30)
}

expb <- exp(0.5+X1-0.5*Xc) 
cure <- exp(-expb) # cure probabilities

 # event times with baseline cdf of a truncated exponential 
U <- runif(n)
d <- rep(NA,n)
T <- round(-6*log( 1+ (1-exp(-20/6))*log(1-(1-cure)*U)/expb ),5) 
T[(runif(n)<cure)] <- 99999 # cured subjects

Tobs <- rep(NA,n)
Tobs <- pmin(C,T) # observed times
Tmax <- max(Tobs[Tobs==T])
d <- (Tobs==T) # censoring indicator
	
Dat <- data.frame(Tobs,d,V,Xc)

## Model estimation
fm <- formula(Surv(Tobs,d) ~ V + Xc)
resSimex <- PTCMestimSIMEX(fm, Dat, errorDistEstim="normal", 
varCov=varCov,  nBack=10000, eps=1e-8, 
Nu=c(0,.5,1,1.5,2), B=50, init=rnorm(3), orderExtrap=1:3, multMaxTime=2)
resSimex
summary(resSimex)}
}

