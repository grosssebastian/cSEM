#' Test for overall model fit
#'
#' Bootstrap-based test for overall model fit. 
#' 
#' `testOMF()` tests the null hypothesis that the population indicator 
#' correlation matrix equals the population model-implied indicator correlation matrix. 
#' Several potential test statistics may be used. `testOMF()` uses the 
#' geodesic distance and the squared Euclidean distance between the
#' sample indicator correlation matrix and the estimated model-implied indicator correlation matrix
#' as well as the standardized root mean square residual (SRMR). 
#' The reference distribution for each test statistic is obtained by 
#' the bootstrap as proposed by \insertCite{Beran1985;textual}{cSEM}. 
#' See also \insertCite{Dijkstra2015;textual}{cSEM} who first suggested the test in 
#' the context of PLS-PM.
#' 
#' @usage testOMF(
#'  .object                = NULL, 
#'  .alpha                 = 0.05, 
#'  .handle_inadmissibles  = c("drop", "ignore", "replace"), 
#'  .R                     = 499, 
#'  .saturated             = FALSE,
#'  .seed                  = NULL,
#'  .verbose               = TRUE
#' )
#' 
#' @inheritParams  csem_arguments
#' 
#' @return
#' A list of class `cSEMTestOMF` containing the following list elements:
#' \describe{
#'   \item{`$Test_statistic`}{The value of the test statistics.}
#'   \item{`$Critical_value`}{The correponding critical values obtained by the bootstrap.}
#'   \item{`$Decision`}{The test decision. One of: `FALSE` (**Reject**) or `TRUE` (**Do not reject**).}
#'   \item{`$Information`}{The `.R` bootstrap values; The number of admissible results;
#'                         The seed used and the number of total runs.}
#' }
#' 
#' @seealso [csem()], [cSEMResults]
#' 
#' @references
#'   \insertAllCited{}
#'   
#' @example inst/examples/example_testOMF.R
#' 
#' @export

testOMF <- function(
  .object                = NULL, 
  .alpha                 = 0.05, 
  .handle_inadmissibles  = c("drop", "ignore", "replace"), 
  .R                     = 499, 
  .saturated             = FALSE,
  .seed                  = NULL,
  .verbose               = TRUE
) {
  
  # Implementation is based on:
  # Dijkstra & Henseler (2015) - Consistent Paritial Least Squares Path Modeling
  
  if(.verbose) {
    cat(rule2("Test for overall model fit based on Beran & Srivastava (1985)",
              type = 3), "\n\n")
  }
  
  ## Match arguments
  .handle_inadmissibles <- match.arg(.handle_inadmissibles)
  
  if(inherits(.object, "cSEMResults_default")) {
    
    x11 <- .object$Estimates
    x12 <- .object$Information
    
    ## Collect arguments
    arguments <- x12$Arguments
    
  } else if(inherits(.object, "cSEMResults_multi")) {
    
    out <- lapply(.object, testOMF,
                  .alpha                = .alpha,
                  .handle_inadmissibles = .handle_inadmissibles,
                  .R                    = .R,
                  .saturated            = .saturated,
                  .seed                 = .seed,
                  .verbose              = .verbose
    )
    ## Return
    return(out)
    
  } else if(inherits(.object, "cSEMResults_2ndorder")) { 
    
    x11 <- .object$First_stage$Estimates
    x12 <- .object$First_stage$Information
    
    x21 <- .object$Second_stage$Estimates
    x22 <- .object$Second_stage$Information
    
    ## Collect arguments
    arguments <- .object$Second_stage$Information$Arguments_original
  } else {
    stop2(
      "The following error occured in the testOMF() function:\n",
      "`.object` must be a `cSEMResults` object."
    )
  }
  
  ### Checks and errors ========================================================
  ## Check if initial results are inadmissible
  if(sum(unlist(verify(.object))) != 0) {
    stop2(
      "The following error occured in the `testOMF()` function:\n",
      "Initial estimation results are inadmissible. See `verify(.object)` for details.")
  }
  
  # Return error if used for ordinal variables
  if(any(x12$Type_of_indicator_correlation %in% c("Polyserial", "Polychoric"))){
    stop2(
      "The following error occured in the `testOMF()` function:\n",
      "Test for overall model fit currently not applicable if polychoric or",
      " polyserial correlation is used.")
  }
  
  ### Preparation ==============================================================
  ## Extract required information 
  X         <- x12$Data
  S         <- x11$Indicator_VCV
  Sigma_hat <- fit(.object,
                   .saturated = .saturated,
                   .type_vcv  = "indicator")
  
  ## Calculate test statistic
  teststat <- c(
    "dG"   = calculateDG(.object),
    "SRMR" = calculateSRMR(.object),
    "dL"   = calculateDL(.object)
  )
  
  ## Transform dataset, see Beran & Srivastava (1985)
  S_half   <- solve(expm::sqrtm(S))
  Sig_half <- expm::sqrtm(Sigma_hat)
  
  X_trans           <- X %*% S_half %*% Sig_half
  colnames(X_trans) <- colnames(X)
  
  # Start progress bar if required
  if(.verbose){
    pb <- txtProgressBar(min = 0, max = .R, style = 3)
  }
  
  # Save old seed and restore on exit! This is important since users may have
  # set a seed before calling testOMF, in which case the global seed would be
  # overwritten by testMGD if not explicitly restored
  old_seed <- .Random.seed
  on.exit({.Random.seed <<- old_seed})
  
  ## Create seed if not already set
  if(is.null(.seed)) {
    .seed <- sample(.Random.seed, 1)
  }
  ## Set seed
  set.seed(.seed)
  
  ### Start resampling =========================================================
  ## Calculate reference distribution
  ref_dist         <- list()
  n_inadmissibles  <- 0
  counter <- 0
  repeat{
    # Counter
    counter <- counter + 1
    
    # Draw dataset
    X_temp <- X_trans[sample(1:nrow(X), replace = TRUE), ]
    
    # Replace the old dataset by the new one
    arguments[[".data"]] <- X_temp
    
    # Estimate model
    Est_temp <- do.call(csem, arguments)               
    
    # Check status (Note: output of verify for second orders is a list)
    status_code <- sum(unlist(verify(Est_temp)))
    
    # Distinguish depending on how inadmissibles should be handled
    if(status_code == 0 | (status_code != 0 & .handle_inadmissibles == "ignore")) {
      # Compute if status is ok or .handle inadmissibles = "ignore" AND the status is 
      # not ok
      
      ref_dist[[counter]] <- c(
        "dG"   = calculateDG(Est_temp),
        "SRMR" = calculateSRMR(Est_temp),
        "dL"   = calculateDL(Est_temp)
      ) 
      
    } else if(status_code != 0 & .handle_inadmissibles == "drop") {
      # Set list element to zero if status is not okay and .handle_inadmissibles == "drop"
      ref_dist[[counter]] <- NA
      
    } else {# status is not ok and .handle_inadmissibles == "replace"
      # Reset counter and raise number of inadmissibles by 1
      counter <- counter - 1
      n_inadmissibles <- n_inadmissibles + 1
    }
    
    # Update progress bar
    if(.verbose){
      setTxtProgressBar(pb, counter)
    }
    
    # Break repeat loop if .R results have been created.
    if(length(ref_dist) == .R) {
      break
    }
  } # END repeat 
  
  # close progress bar
  if(.verbose){
    close(pb)
  }
  
  # Delete potential NA's
  ref_dist1 <- Filter(Negate(anyNA), ref_dist)
  
  # Combine
  ref_dist_matrix <- do.call(cbind, ref_dist1) 
  ## Compute critical values (Result is a (3 x p) matrix, where p is the number
  ## of quantiles that have been computed (1 by default)
  .alpha <- .alpha[order(.alpha)]
  critical_values <- matrixStats::rowQuantiles(ref_dist_matrix, 
                                               probs =  1-.alpha, drop = FALSE)
  
  ## Compare critical value and teststatistic
  decision <- teststat < critical_values # a logical (3 x p) matrix with each column
  # representing the decision for one
  # significance level. TRUE = no evidence 
  # against the H0 --> not reject
  # FALSE --> reject
  
  # Return output
  out <- list(
    "Test_statistic"     = teststat,
    "Critical_value"     = critical_values, 
    "Decision"           = decision, 
    "Information"        = list(
      "Bootstrap_values"   = ref_dist,
      "Number_admissibles" = ncol(ref_dist_matrix),
      "Seed"               = .seed,
      "Total_runs"         = counter + n_inadmissibles
    )
  )
  
  ## Set class and return
  class(out) <- "cSEMTestOMF"
  return(out)
}