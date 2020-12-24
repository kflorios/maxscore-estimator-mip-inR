require(matrixStats)

readXyw <- function() {
  #Reads X,y,w of given max score problem
  X <- read.table("X_Horowitz.txt")
  X <- X[,-1]
  X <- as.matrix(X)
  y <- read.table("y_Horowitz.txt")
  y <- y[,-1]
  y <- as.vector(y)
  w <- read.table("w_Horowitz.txt")
  w <- w[,-1]
  w <- as.vector(w)
  results1 <- list(X = X, y = y, w = w)
  return(results1)  
}


standardizeX <- function(X) {
  require(pracma)
  #Standardizes X
  mu <- colMeans(X)
  sigma <- colSds(X)
  testX <- (X - repmat(mu,dim(X)[1],1)) / repmat(sigma,dim(X)[1],1) 
  p <- dim(X)[2]
  for (j in 1:p) {
    if (is.nan(testX[1,j])) {
      X[,j] <- X[,j]
    }
    else {
      X[,j] <- testX[,j]
    }
  }
  results2 <- list(X = X, mu = mu, sigma = sigma)
  return(results2)  
}


definecAb <- function(X,y,w) {
  
  #Defines c,A,b for milp.R
  require(pracma)
  n <- dim(X)[1]
  p <- dim(X)[2]
  
  c1 <- repmat(-1,1,n)
  c2 <- repmat(0,1,p)
  c <- cbind(c1,c2)
  
  d=10
  #d=5
  M <- numeric(n)
  for (i in 1:n){
    M[i] <- abs(X[i,1])+abs(X[i,-1])%*%t(repmat(d,1,p-1))
  }
  Abin <- diag(M,n,n)
  Areal <- matrix(0,n,p)
  for (i in 1:n) {
    for (j in 1:p) {
      Areal[i,j] <- (1-2*y[i])*X[i,j]
    }
  }
  A <- cbind(Abin,Areal)
  b <- M
  results3 <- list(c = c, A = A, b = b)
  return(results3)  
}


definelbub <- function(X) {

  require(pracma)
  #Defines lb,ub for milp.R
  d=10
  #d=5
  n <- dim(X)[1]
  p <- dim(X)[2]
  lb1 <-repmat(0,1,n)
  lb2 <- repmat(-d,1,p)
  lb2[1] <- 1
  lb <- cbind(lb1,lb2)
  
  ub1 <- repmat(1,1,n)
  ub2 <- repmat(d,1,p)
  ub2[1] <- 1
  ub <- cbind(ub1,ub2)
  
  Aeq <- NULL
  beq <- NULL
  
  best <- 0
  
  results4 <- list(lb = lb, ub = ub, Aeq = Aeq, beq = beq, n = n, best = best)
  return(results4)  
}


milp_cplex <- function(c,A,b,Aeq,beq,lb,ub,n, best) {
 
  # Solves a mixed integer lp using cplex 20.1
  # c: is objective function coefficients A: is constraint matrix b: is constraint vector
  # lb: lower bound ub: upper bound n: number of 0-1 variables
  # best: is best solution so far
  # Note this uses the Rcplex Interface documented at
  # https://cran.r-project.org/web/packages/Rcplex/index.html
  # Also, it assumes first n variables must be integer.
  # The MIP equations of the maximum score estimator are available at
  # Florios. K, Skouras, S. (2008) Exact computation of maximum weighted
  # score estimators, Journal of Econometrics 146, 86-91.
  # Writen by Kostas Florios, December 24, 2020
  #
  # C:\Program Files\IBM\ILOG\CPLEX_Studio201\cplex\bin\x64_win64
  #
  # C:\Program Files\IBM\ILOG\CPLEX_Studio201\cplex\include\ilcplex
  #
  
  require(pracma)
  vtype <- c(rep("B",length(b)), rep("C",dim(c)[2]-length(b)))
  
  cvec <- c
  Amat <- A
  bvec <- b
  Qmat <- NULL
  lb <- lb
  ub <- ub
  control <- list()
  objsense <- "min"
  sense <- "L"
  
  
  ptm <- proc.time() # Start the clock!
  out <- Rcplex(cvec, Amat, bvec, Qmat = NULL,
                  lb = lb, ub = ub, control = list(),
                  objsense = c("min"), sense = "L", vtype = vtype, n = 1)

  elapsed_time <- proc.time() - ptm  # Stop the clock
  cat("Optimization returned status: ",out$status,"\n")
  cat("Objective Value: ",out$obj,"\n")
  cat('(Wall clock) Time elapsed (s): ',elapsed_time[3],"\n")
  cat('Decision variables: the last ones (after the 1.00) are betas\n')
  
  x <- out$xopt
  x <- x[(length(b)+1):dim(c)[2]]
  score <- -out$obj
  feasible <- out$status
  time <- elapsed_time
  results5 <- list(x = x, score = score, feasible = feasible, time = time)
  
  return(results5)  
}


denormalizeEstimates <- function(estimatesNorm,mu,sigma) {
 
  #denormalized estimatesNorm obtained by Cplex MIP to estimatesRaw, which
  #are meaningful to the user
  
  #quick and dirty implementation, based on GAMS and Fortran Analogues
  p <- length(estimatesNorm)
  betaNorm <- estimatesNorm
  
  betaRaw <- numeric(p)
  betaHelp <- numeric(p)
  
  for (j in 1:p) {
    if (sigma[j] !=0 ) {
      betaHelp[j] <- betaNorm[j] / sigma[j]
    }
    if (sigma[j] ==0 ) {
      for (jj in 1:p) {
          if (sigma[jj] != 0) {
            betaHelp[j] <- betaHelp[j] - betaNorm[jj]*mu[jj]/sigma[jj]
          }
          else {
            jj0 <- jj
          }
      }
      betaHelp[j] <- betaHelp[j] + betaNorm[jj0]
    }
  }
  
  for (j in 1:p) {
    betaRaw[j] <- betaHelp[j] / betaHelp[1]
  }
  
  estimatesRaw <- betaRaw
  results6 <- list(estimatesRaw = estimatesRaw)
  return(results6)  
}

