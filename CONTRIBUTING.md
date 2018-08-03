
## Notes to contributors

Stick to the structure, design choices and style conventions described
below. For questions: please contact the
[author](mailto:manuel.steiner@uni-wuerzburg.de).

### Structure

The package structure is best understood with reference to a
(hierarchically organized) company. In analogy to company departments,
two separate “function departments” exist:

  - **Estimation functions**
  - **Postestimation functions**

Each department is hierarchically structured. All functions that do not
belong to one of the departments are considered **utility functions**.
To stay in the picture, they are best understood as external consultants
in charge of one specific task that is not meaningfully classified as
belonging to one of the two departments.

#### Estimation functions:

Estimation functions are all functions involved in the
estimation/calculation of the quantities of the measurement and the path
model. There are:

  - **2 toplevel functions** (`csem()` and `cca()`). These functions +
    the postestimation function `summary()` (see below) should be
    sufficient for the end user 95% of the time. Both functions
    eventually call `foreman()`.
  - **1 midlevel function**, `foreman()`, that acts like a foreman by
    collecting all (estimation) tasks, distributing them to lower level
    functions, and eventually recollecting all of their results.
  - **Lowlevel (helper) functions** that perform one specific task. A
    distinction is made between:
      - **Exported helper functions**: Functions that are exported to be
        applied directly by the end user if needed (e.g. `parseModel()`
        or `calculateWeightsPLS()`).
      - **Internal helper functions**: Functions that are not exported.
        These functions can be accessed via `csem::` but they are not
        generally useful to the end user (e.g. `calculateConstructVCV()`
        or `classifyConstructs()`).

#### Postestimation functions

**Postestimation functions**. Postestimation functions are generic
functions to be applied to an object resulting from a call to `csem()`
or `cca()`. Depending on the class of the resulting object (e.g.
`cSEMResults` or `cSEMSummary`) different methods are dispatched. Most
postestimation functions like `test()` (not yet implemented) act like a
foreman by the collect-distribute-recollect strategy as implemented in
the `foreman()` function. Therefore postestimation functions are
generally also hierarchical. Currently only a subset of these functions
is implemented:

  - 1 Top-level function:
      - `summary()` with class `cSEMSummary`
  - Mid-level functions:
      - `status()` with class `cSEMStatus`
      - `fit()` with class `cSEMFit`
      - `coef()` with class `cSEMCoef`
      - `effects()` with class `cSEMEffects`
      - `test()` with class `cSEMTest`
  - Low-level functions:
      - `test_fit()` with class `cSEMTestFit`
      - `test_MICOM()` with class `cSEMTestMICOM`
      - `test_MGA()` with class `cSEMTestMGA`

Each function has (will eventually have) a distinct class and a
corresponding `print` method.

### Design choices

  - The only OO system used is the S3 system. No S4 classes will be
    allowed\! (Strong recommendation by Yves Rosseel)
  - Whenever you subset a matrix using `[` use: `[..., ..., drop =
    FALSE]` to avoid accidentally droping the `dim` attributes.

### Style/Naming

Stick to [this styleguide](http://style.tidyverse.org/) with the
following exceptions/additions:

1.  Function and class names are always CamelCase. Function names should
    contain a verb followed by a noun like: `processData()`,
    `calculateValue()`.
2.  Verbs in function names should be consistent across the whole
    package. Avoid to mix synonyms. Example: `computeValue()` vs.
    `calculateValue()`. This package always uses `calculate` instead of
    `compute`. Similarly, `method` vs e.g. `approach`. This package
    always uses `approach` instead of `method`.
3.  Use plural in function/object names if the main output is more than
    one element, like `scaleWeights()`, `calculateProxies()`,
    `handleArgs()` etc. but stick to singular in other cases like
    `parseModel()`.
4.  Strive for meaningful argument names even if they are a bit longer
    than usual. People are much better at remembering arguments like
    `respect_structural_model` compared to something like `resp_sm`.
    Naming should also be consistent if possible. For example: any
    argument that describes a method or an approach should be named
    `.appraoch_*`.
5.  Argument names always start with a dot to distinguish them from
    other objects.
6.  Indentation: It is OK to align function arguments indented by two
    spaces below the function name instead of where the function starts
    if this help with clarity.

<!-- end list -->

``` r
## Both ok but second is prefered in this case
calculateInnerWeightsPLS <- function(.S                           = NULL,
                                     .W                           = NULL,
                                     .csem_model                  = NULL,
                                     .PLS_weight_scheme_inner     = c("centroid",
                                                                      "factorial", 
                                                                      "path"),
                                     .PLS_ignore_structural_model = NULL
                                     ) { }

calculateInnerWeightsPLS <- function(
  .S                            = NULL,
  .W                            = NULL,
  .csem_model                   = NULL,
  .PLS_weight_scheme_inner      = c("centroid","factorial", "path"),
  .PLS_ignore_structural_model  = NULL
  ) { }
```

### Matrices

  - Whenever possible: variables belong in columns, observations belong
    to rows. This implies: whenever a matrix contains observations,
    variables are in columns, no matter if they are indicators, proxies,
    errors or anything else.
  - Covariance matrices: indicators **always** belong to columns and
    proxies to rows, i.e., the matrix of weights \(W\) for PLS is
    therefore \((J \times K)\) where \(J\) is the number of proxies and
    \(K\) the number of indicators.
  - Naming: matrices within the package should be named according to the
    naming schemes of the related SEM literature.

### Helper functions

Exported helper functions should be written as autonomous as possible in
a sense that they can be used without having to jump to a mother
function in order to allow researchers using the package to use helper
function the way the need it. Flexibility will come at the price of code
repetition (i.e. most exported helper functions will have to have a
`parseModel()` + `processDate()` statement at the beginning) to make
them autonomous.

Internal helper functions on the other hand do not need to be
autonomous. Here code compactness is preferred.

### Arguments

All arguments used by any of the functions in the package (including
internal functions) are centrally collected in the file
`zz_arguments.R`. Whenever a new argument is introduced:

1.  Add the new argument + a description to the `cSEMArguments` list by
    writing `@param <argument> Description. Default.`
2.  Add the argument to the `args`-list in `args_default()` and provide
    a default value.