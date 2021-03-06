% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model-class.R
\docType{methods}
\name{summary}
\alias{summary}
\alias{summary,posterior-method}
\alias{summary,list-method}
\alias{summary,hyper-method}
\title{ggdmc Summary Methods}
\usage{
summary(object, ...)

\S4method{summary}{posterior}(object, start = 1, end = NA,
  prob = c(0.025, 0.25, 0.5, 0.75, 0.975), recovery = FALSE, ps = NA,
  verbose = FALSE, digits = max(3, getOption("digits") - 3))

\S4method{summary}{list}(object, start = 1, end = NA, prob = c(0.025,
  0.25, 0.5, 0.75, 0.975), recovery = FALSE, ps = NA,
  verbose = FALSE, digits = max(3, getOption("digits") - 3))

\S4method{summary}{hyper}(object, hyper = TRUE, start = 1, end = NA,
  prob = c(0.025, 0.25, 0.5, 0.75, 0.975), recovery = FALSE, ps = NA,
  type = 1, verbose = FALSE, digits = max(3, getOption("digits") -
  3))
}
\arguments{
\item{object}{an object storing posterior samples.}

\item{...}{Additional argument passing via dot dot dot.}

\item{start}{start from which iteration.}

\item{end}{end at which iteration. For example, set
\code{start = 101} and \code{end = 1000}, instructs the function to
calculate from 101st to 1000th iteration.}

\item{prob}{a numeric vector, indicating the quantiles to calculate}

\item{recovery}{a Boolean switch indicating if samples are from a recovery
study.}

\item{ps}{true parameter values.  This is only for recovery studies}

\item{verbose}{print more information}

\item{digits}{printing digits}

\item{hyper}{a Boolean switch to plot hyper parameters}

\item{type}{calculate type 1 = location or type 2 = scale hyper parameters}
}
\description{
Summarise posterior samples. Note when recovery = TRUE, the prob vector
will be fixed at the default values.
}
\examples{
\dontrun{
model <- BuildModel(
     p.map    = list(a = "1", v = "F", z = "1", d = "1", sz = "1", sv = "1",
                t0 = "1", st0 = "1"),
    match.map = list(M = list(s1 = "r1", s2 = "r2")),
    factors   = list(S = c("s1", "s2"), F = c("f1", "f2")),
    constants = c(st0 = 0, d = 0),
    responses = c("r1", "r2"),
    type      = "rd")
npar <- model@npar

## Population distribution
pop.mean  <- c(a=2,   v.f1=4,  v.f2=3,  z=0.5, sz=0.3, sv=1,  t0=0.3)
pop.scale <- c(a=0.5, v.f1=.5, v.f2=.5, z=0.1, sz=0.1, sv=.3, t0=0.05)
pop.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale,
  lower = c(0,-5, -5, 0, 0, 0, 0),
  upper = c(5, 7,  7, 1, 2, 1, 1))

## Simulate some data
dat <- simulate(model, nsub = 30, nsim = 30, prior = pop.prior)
dmi <- BuildDMI(dat, model)
ps <- attr(dat, "parameters")

p.prior <- BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale*5,
  lower = c(0,-5, -5, 0, 0, 0, 0),
  upper = c(5, 7,  7, 1, 2, 1, 1))

mu.prior <- ggdmc::BuildPrior(
  dists = rep("tnorm", npar),
  p1    = pop.mean,
  p2    = pop.scale*5,
  lower = c(0,-5, -5, 0, 0, 0, 0),
  upper = c(5, 7,  7, 1, 2, 1, 1)
)
sigma.prior <- BuildPrior(
  dists = rep("beta", npar),
  p1    = c(a=1, v.f1=1,v.f2 = 1, z=1, sz=1, sv=1, t0=1),
  p2    = rep(1, npar),
  upper = rep(2, npar))

priors <- list(pprior=p.prior, location=mu.prior, scale=sigma.prior)

## Sampling
## Processing time: 394.37 secs.
fit0 <- StartNewsamples(dmi, priors, thin = 2)
fit  <- run(fit0)
fit  <- run(fit, 1e2, add=TRUE)

## By default the type = 1 for location parameters
## When recovery = TRUE, one must enter the true parameter to ps
est0 <- summary(fit, recovery = TRUE, ps = pop.mean, verbose = TRUE)
## Explicitly enter type = 1
est0 <- summary(fit, recovery = TRUE, ps = pop.mean,  type=1, verbose = TRUE)
est0 <- summary(fit, recovery = TRUE, ps = pop.scale, type=2, verbose = TRUE)

## When recovery = FALSE (default), the function return parameter estimates
est0 <- summary(fit, verbose = TRUE, type=1)
est0 <- summary(fit, verbose = TRUE, type=2)

## To estimate individual participants, one must enter hyper = FALSE for a
## hierarchical model fit
est0 <- summary(fit, hyper=FALSE, verbose = TRUE)
}
}
