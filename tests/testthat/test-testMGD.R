context("testMGD")

## Model linear
model_linear <- "
# Structural model
eta2 ~ eta1
eta3 ~ eta1 + eta2

# (Reflective) measurement model
eta1 =~ y11 + y12 + y13
eta2 <~ y21 + y22 + y23
eta3 =~ y31 + y32 + y33
"

## Model nonlinear
model_nonlinear <- "
# Structural model
eta2 ~ eta1
eta3 ~ eta1 + eta2 + eta1.eta2

# (Reflective) measurement model
eta1 =~ y11 + y12 + y13
eta2 <~ y21 + y22 + y23
eta3 =~ y31 + y32 + y33
"

## Model 2ndorder
# model_2ndorder <- "
# # Structural model
# eta2 ~ eta1
# eta3 ~ eta1 + eta2 + eta1.eta2
# 
# # (Reflective) measurement model
# eta1 =~ y11 + y12 + y13
# eta2 <~ y21 + y22 + y23
# eta3 =~ y31 + y32 + y33
# "

## Data
dat <- list(threecommonfactors, 
            threecommonfactors[1:200, ], 
            threecommonfactors[130:250,])

## Estimates (.R is small to save computation time)
res_error <- csem(threecommonfactors, model_linear)
res_nonlinear <- csem(dat, model_nonlinear, .resample_method = "bootstrap", .R = 50)
res_linear <-  csem(dat, model_linear, .resample_method = "bootstrap", .R = 50)
# res_2ndorder <-  csem(dat, model_linear, .resample_method = "bootstrap", .R = 50)

# ==============================================================================
# Tests 
# ==============================================================================
## Errors
test_that("Not providing a cSEMResults_multi object causes an error", {
  expect_error(
    testMGD(res_error)
  )
})

test_that(".approach_mgd = 'Klesel' does not work for linear models", {
  expect_error(
    testMGD(res_nonlinear, .approach_mgd = "Klesel")
  )
  expect_error(
    testMGD(res_nonlinear, .approach_mgd = "all")
  )
})

test_that(".approach_mgd = 'Sarstedt' cant be combined with .handle_inadmissibles = 'drop'", {
  expect_error(
    testMGD(res_nonlinear, .approach_mgd = "Sarstedt", .handle_inadmissibles = "drop")
  )
  expect_error(
    testMGD(res_nonlinear, .approach_mgd = "all", .handle_inadmissibles = "drop")
  )
})

## Correct

test_that("All .approach_mgd options work", {
  expect_output(
    testMGD(
      .object       = res_linear,
      .approach_mgd = "Klesel",
      .R_permutation = 10
    )
  )
  expect_output(
    testMGD(
      .object       = res_linear,
      .approach_mgd = "Chin",
      .R_permutation = 10
    )
  )
  expect_output(
    testMGD(
      .object       = res_linear,
      .approach_mgd = "Sarstedt",
      .R_permutation = 10,
      .handle_inadmissibles = "ignore"
    )
  )
  expect_output(
    testMGD(
      .object       = res_linear,
      .approach_mgd = "all",
      .R_permutation = 10,
      .handle_inadmissibles = "ignore"
    )
  )
})

test_that("Chin and Sarstedt work for nonlinear models", {
  expect_output(
    testMGD(
      .object       = res_nonlinear,
      .approach_mgd = "Chin",
      .R_permutation = 10
    )
  )
  expect_output(
    testMGD(
      .object       = res_nonlinear,
      .approach_mgd = "Sarstedt",
      .R_permutation = 10,
      .handle_inadmissibles = "ignore"
    )
  )
})

# test_that("Chin and Sarstedt work for '2ndorder' models", {
#   expect_output(
#     testMGD(
#       .object       = res_linear,
#       .approach_mgd = "Chin",
#       .R_permutation = 10
#     )
#   )
#   expect_output(
#     testMGD(
#       .object       = res_linear,
#       .approach_mgd = "Chin",
#       .R_permutation = 10
#     )
#   )
#   expect_output(
#     testMGD(
#       .object       = res_nonlinear,
#       .approach_mgd = "Sarstedt",
#       .R_permutation = 10,
#       .handle_inadmissibles = "ignore"
#     )
#   )
# })