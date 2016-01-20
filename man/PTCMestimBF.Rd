\name{PTCMestimBF}
\alias{PTCMestimBF}
\alias{PTCMestimBF.default}
\alias{PTCMestimBF.formula}
\alias{print.PTCMestimBF}
\alias{summary.PTCMestimBF}
\alias{print.summary.PTCMestimBF}

%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Corrected score approach
}
\description{
Fits a Semiparametric Promotion Time Cure Model, taking into account (using a corrected score approach) or not the measurement error in the covariates, using a backfitting approach to maximize the likelihood. Both methods were introduced in Ma and Yin (2008).
}
\usage{
\method{PTCMestimBF}{default}(x, y, varCov, init, nBack=10000, eps=1e-8, multMaxTime=2,...)
\method{PTCMestimBF}{formula}(formula, data=list(), ...)
\method{print}{PTCMestimBF}(x,...)
\method{summary}{PTCMestimBF}(object,...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{ a numerical matrix containing the explanatory variables as columns (without a column of 1s for the intercept).}
  \item{y}{ the response, a survival object returned by the \code{Surv} function. }
  \item{varCov}{ the square variance-covariance matrix of measurement error, with as many rows as regression parameters (including the intercept).}
  \item{init}{ a numerical vector of initial values for the regression parameters.}
  \item{nBack}{ an integer specifying the maximal number of iterations in the backfitting procedure. }
  \item{eps}{ convergence criterion. Convergence is declared if the euclidian norm of the vector of changes in the estimated parameters and the euclidian norm of the  score equations evaluated at these values are smaller than \code{eps}. }
  \item{multMaxTime}{ a positive number controlling the time allowed, in one iteration of the backfitting procedure, to function \code{nleqslv} (used to solve the score equations) to converge.  }
  \item{formula}{a formula object, in which the response is a survival object returned by the \code{Surv} function.}
  \item{data}{a dataframe containing the variables appearing in the model.}
  \item{object}{ an object of class \code{"PTCMestimBF"}, i.e., a fitted model.}
  \item{\dots}{ not used. }
}
\details{
This method assumes normally distributed measurement error. The diagonal elements of the matrix \code{varCov} corresponding to covariates without error (as is the case for the intercept) have to be set to 0.
}
\value{
An object of class \code{PTCMestimBF}, i.e. a list including the following elements:
	\item{coefficients }{The estimated values of the regression parameters.}
	\item{estimCDF }{The estimated baseline cumulative distribution function.}
	\item{vcov}{The estimated variance-covariance matrix of the estimated regression parameters.}
	\item{classObs}{An integer vector of length 3: the number of censored individuals not considered as cured for the estimation, the number of events, and the number of individuals considered as cured for the estimation.}
	\item{flag}{Termination code: 1 if converged, 2 otherwise.}
	\item{endK}{Number of iterations performed in the backfitting procedure.}
}
\references{
Bertrand A., Legrand C., Carroll R.J., De Meester C., Van Keilegom I. (2015) Inference in a Survival Cure Model with Mismeasured Covariates using a SIMEX Approach. Submitted.

Ma, Y., Yin, G. (2008) Cure rate models with mismeasured covariates under transformation. Journal of the American Statistical Association, 103, 743-756. DOI: 10.1198/016214508000000319
}



%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
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
#colnames(Dat) <- c("Tobs","d","V","Xc")


## Model estimation
fm <- formula(Surv(Tobs,d) ~ V + Xc)
resMY <- PTCMestimBF(fm, Dat, varCov=varCov, init=rnorm(3))
resMY
summary(resMY)
}

