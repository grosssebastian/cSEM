#' Verify admissibility
#'
#' Verify admissibility of the estimated quantities in `.object`. 
#' 
#' Results exhibiting one of the following defects are deemed inadmissible: 
#' non-convergence of the algorithm used to obtain weights, loadings and/or 
#' (congeneric) reliabilities larger than 1, a construct variance-covariance (VCV) and/or
#' model-implied VCV matrix that is not positive semi-definite.
#' 
#' If the two stage approach was used for models containing second order 
#' constructs, both the first and the second stage are checked separately.
#' 
#' Currently, a model-implied indicator VCV matrix for nonlinear model is not
#' available. `verify()` therefore skips the check for positive definitness of the
#' model-implied indicator VCV matrix for nonlinear models and returns "ok".
#'
#' @inheritParams csem_arguments
#'
#' @seealso [csem()], [cSEMResults]
#'
#' @return A logical vector indicating which (if any) problem occurred. 
#'   A `FALSE` indicates that the specific problem has not occured. For models containg second order
#'   constructs estimated by a two stage approach a list of two such vectors 
#'   (one for the first and one for the second stage) is returned. Status codes are:
#'  \itemize{
#' \item 1: The algorithm has converged.
#' \item 2: All absolute standardized loading estimates are smaller than or equal to 1.
#'   A violation implies either a negative variance of the measurement error or
#    a correlation larger than 1.
#' \item 3: The construct VCV is positive semi-definite.
#' \item 4: All reliability estimates are smaller than or equal to 1. 
#' \item 5: The model-implied indicator VCV is positive semi-definite. 
#'   This is only checked for linear models (including models containing 
#'   second-order constructs).
#' }
#'
#' @export
 
verify <- function(.object){
  
  if(inherits(.object, "cSEMResults_multi")) {
    out <- lapply(.object, verify)
    
    class(out) <- c("cSEMVerify", "cSEMVerify_multi")
    out
  } else if(inherits(.object, "cSEMResults_2ndorder")) {
    out <- lapply(.object, verify)
    names(out) <- c("First_stage", "Second_stage")
    
    class(out) <- c("cSEMVerify", "cSEMVerify_2ndorder")
    out
  } else {

    x1 <- .object$Information
    x2 <- .object$Estimates  
    
    stat <- c("1" = FALSE, "2" = FALSE, "3" = FALSE, "4" = FALSE, "5" = FALSE)
    
    if(!(is.null(x1$Weight_info$Convergence_status) || x1$Weight_info$Convergence_status)) {
      stat["1"] <- TRUE
    }
    
    if(max(abs(x2$Loading_estimates)) > 1) {
      stat["2"] <- TRUE
    }
    
    if(!matrixcalc::is.positive.semi.definite(x2$Construct_VCV)) {
      stat["3"] <- TRUE
    }
    
    if(max(x2$Reliabilities) > 1) {
      stat["4"] <- TRUE
    }
    
    if(x1$Model$model_type == "Linear" && 
       !matrixcalc::is.positive.semi.definite(fit(.object, 
                                                  .saturated = FALSE,
                                                  .type_vcv = 'indicator'))) {
      stat["5"] <- TRUE
    }
    
    class(stat) <- "cSEMVerify"
    stat 
  }
}