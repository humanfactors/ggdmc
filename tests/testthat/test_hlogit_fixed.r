require(ggdmc); require(data.table); require(ggplot2); require(gridExtra)
require(testthat)
context("hlogit_fixed")


rm(list = ls())
  setwd("/media/yslin/KIWI/Documents/ggdmc/")
  model <- BuildModel(
    p.map     = list(a0 = "1", a1 = "1", a2 = "1", a3 = "1", b = "1"),
    match.map = NULL,
    regressors= NULL,
    factors   = list(S = c("s1", "s2"), E = c("e1", "e2")),
    responses = "r1",
    constants = NULL,
    type      = "logit")
  npar <- length(GetPNames(model))

  pop.location <- c(a0 = -.55, a1 = .08, a2 = -.81, a3 = 1.35, b = .27)
  pop.scale    <- c(a0 = .19, a1 = .30, a2 = .41, a3 = .26, b = .15)
ntrial <- 500
nsub <- 12
  pop.prior  <-BuildPrior(
    dists = rep("tnorm", npar),
    p1    = pop.location,
    p2    = pop.scale,
    lower = c(NA, NA, NA, NA, 0),
    upper = rep(NA, npar))
  plot(pop.prior, ps = pop.location)
  dat <- simulate(model, nsub = nsub, nsim = ntrial, prior = pop.prior)
  dmi <- BuildDMI(dat, model)

  ps <- attr(dat, "parameters")
  round(colMeans(ps), 2)
  round(matrixStats::colSds(ps), 2)

  start  <- BuildPrior(
    dists = c(rep("tnorm2", npar)),
    p1    = c(a0 = -.55, a1 = 0.08, a2 = -.81, a3 = 1.35, b = .267),
    p2    = rep(1e-3, npar),
    lower = rep(NA, npar),
    upper = rep(NA, npar))

  p.prior  <-BuildPrior(
    dists = c(rep("tnorm2", npar)),
    p1    = c(a0 = 0, a1 = 0, a2 = 0, a3 = 0, b = 0),
    p2    = rep(1e-6, npar),
    lower = rep(NA, npar),
    upper = rep(NA, npar))
  plot(p.prior, ps = ps)
  print(p.prior)
  #
  # start <- BuildPrior(
  #   dists = rep("tnorm", npar),
  #   p1    = pop.location,
  #   p2    = pop.scale * 10,
  #   lower = rep(NA, npar),
  #   upper = rep(NA, npar))
  # prior <- BuildPrior(
  #   dists = c(rep("constant", 4), "tnorm"),
  #   p1    = c(a0 = NA, a1 = NA, a2 = NA, a3 = NA, b = 0),
  #   p2    = c(a0 = 0, a1 = 0, a2 = 0, a3 = 0, b = NA),
  #   lower = c(NA, NA, NA, NA, 0),
  #   upper = rep(NA, npar))
  # print(start)
  # print(prior)
  # plot(start)
  # plot(p.prior, ps = ps)


  # mu.prior  <-BuildPrior(
  #   dists = rep("tnorm", npar),
  #   p1    = c(alpha = 200, beta = 0, sigma = 2),
  #   p2    = c(alpha = 50,  beta = 5, sigma = 5),
  #   lower = c(NA, NA, 0),
  #   upper = rep(NA, npar))
  # sigma.prior  <-BuildPrior(
  #   dists = rep("tnorm", npar),
  #   p1    = c(alpha = 100, beta = 5, sigma = 5),
  #   p2    = c(alpha = 50,  beta = 5, sigma = 5),
  #   lower = c(NA, NA, 0),
  #   upper = rep(NA, npar))
  # pp.prior <- list(mu.prior, sigma.prior)
  # plot(mu.prior, ps = pop.mean)
  # plot(sigma.prior, ps = pop.scale)

  ## shape, scale
  # dprior(ps[1,], sigma.prior)
  # dgamma(ps[1,], .001, scale = .001, log = TRUE)

  ## Sampling -----------
  setwd("/media/yslin/KIWI/Documents/ggdmc_lesson/")
  path <- c("data/Lesson4/ggdmc_4_1_hlogit_fixed.rda")
  # load(path)

  fit0 <- Startlogits(5e2, dmi, start, p.prior, thin = 1)
  fit <- run(fit0, ncore = 1)
  names(fit) <- 1:length(fit)
  names(fit)

  thin <- 4
  repeat {
    fit <- run(RestartManysamples(5e2, fit, thin = thin), ncore = 1)
    save(fit0, fit, file = path[1])
    rhat <- gelman(fit, verbose = TRUE)
    if (all(sapply(rhat, function(x) x$mpsrf) < 1.2)) break
    thin <- thin * 2
  }
  cat("Done ", path[1], "\n")
  setwd("/media/yslin/KIWI/Documents/ggdmc/")
  ggdmc:::plot_many(fit, 1, 500, T, F, F, F, 3)

  p0 <- plot(fit[[1]])
  p0 <- plot(fit)
  p0 <- plot(fit, start = 151)
  est1 <- summary(fit, recover = TRUE, start = 151, ps = ps, verbose = T)
  colMeans(ps)
  matrixStats::colSds(ps)

  est2 <- summary(fit,  start = 151)
  round(est2, 2)
  round(ps, 2)
  est2[1:4, ] - ps



