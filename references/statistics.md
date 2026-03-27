# Statistics — Quick Reference

> Non-obvious behaviors, gotchas, and tricky defaults for R functions.
> Only what Claude doesn't already know.

---

## chisq.test

- `correct = TRUE` (default) applies Yates continuity correction for **2x2 tables only**.
- `simulate.p.value = TRUE`: Monte Carlo with `B = 2000` replicates (min p ~ 0.0005). Simulation assumes **fixed marginals** (Fisher-style sampling, not the chi-sq assumption).
- For goodness-of-fit: pass a vector, not a matrix. `p` must sum to 1 (or set `rescale.p = TRUE`).
- Return object includes `$expected`, `$residuals` (Pearson), and `$stdres` (standardized).

---

## wilcox.test

- `exact = TRUE` by default for small samples with no ties. With ties, normal approximation used.
- `correct = TRUE` applies continuity correction to normal approximation.
- `conf.int = TRUE` computes Hodges-Lehmann estimator and confidence interval (not just the p-value).
- Paired test: `paired = TRUE` uses signed-rank test (Wilcoxon), not rank-sum (Mann-Whitney).

---

## fisher.test

- For tables larger than 2x2, uses simulation (`simulate.p.value = TRUE`) or network algorithm.
- `workspace` controls memory for the network algorithm; increase if you get errors on large tables.
- `or` argument tests a specific odds ratio (default 1) — only for 2x2 tables.

---

## ks.test

- Two-sample test or one-sample against a reference distribution.
- Does **not** handle ties well — warns and uses asymptotic approximation.
- For composite hypotheses (parameters estimated from data), p-values are **conservative** (too large). Use `dgof` or `ks.test` with `exact = NULL` for discrete distributions.

---

## p.adjust

- Methods: `"holm"` (default), `"BH"` (Benjamini-Hochberg FDR), `"bonferroni"`, `"BY"`, `"hochberg"`, `"hommel"`, `"fdr"` (alias for BH), `"none"`.
- `n` argument: total number of hypotheses (can be larger than `length(p)` if some p-values are excluded).
- Handles `NA`s: adjusted p-values are `NA` where input is `NA`.

---

## pairwise.t.test / pairwise.wilcox.test

- `p.adjust.method` defaults to `"holm"`. Change to `"BH"` for FDR control.
- `pool.sd = TRUE` (default for t-test): uses pooled SD across all groups (assumes equal variances).
- Returns a matrix of p-values, not test statistics.

---

## shapiro.test

- Sample size must be between 3 and 5000.
- Tests normality; low p-value = evidence against normality.

---

## kmeans

- `nstart > 1` recommended (e.g., `nstart = 25`): runs algorithm from multiple random starts, returns best.
- Default `iter.max = 10` — may be too low for convergence. Increase for large/complex data.
- Default algorithm is "Hartigan-Wong" (generally best). Very close points may cause non-convergence (warning with `ifault = 4`).
- Cluster numbering is arbitrary; ordering may differ across platforms.
- Always returns k clusters when k is specified (except Lloyd-Forgy may return fewer).

---

## hclust

- `method = "ward.D2"` implements Ward's criterion correctly (using squared distances). The older `"ward.D"` did not square distances (retained for back-compatibility).
- Input must be a `dist` object. Use `as.dist()` to convert a symmetric matrix.
- `hang = -1` in `plot()` aligns all labels at the bottom.

---

## dist

- `method = "euclidean"` (default). Other options: `"manhattan"`, `"maximum"`, `"canberra"`, `"binary"`, `"minkowski"`.
- Returns a `dist` object (lower triangle only). Use `as.matrix()` to get full matrix.
- `"canberra"`: terms with zero numerator and denominator are **omitted** from the sum (not treated as 0/0).
- `Inf` values: Euclidean distance involving `Inf` is `Inf`. Multiple `Inf`s in same obs give `NaN` for some methods.

---

## prcomp vs princomp

- `prcomp` uses **SVD** (numerically superior); `princomp` uses `eigen` on covariance (less stable, N-1 vs N scaling).
- `scale. = TRUE` in `prcomp` standardizes variables; important when variables have very different scales.
- `princomp` standard deviations differ from `prcomp` by factor `sqrt((n-1)/n)`.
- Both return `$rotation` (loadings) and `$x` (scores); sign of components may differ between runs.

---

## density

- Default bandwidth: `bw = "nrd0"` (Silverman's rule of thumb). For multimodal data, consider `"SJ"` or `"bcv"`.
- `adjust`: multiplicative factor on bandwidth. `adjust = 0.5` halves the bandwidth (less smooth).
- Default kernel: `"gaussian"`. Range of density extends beyond data range (controlled by `cut`, default 3 bandwidths).
- `n = 512`: number of evaluation points. Increase for smoother plotting.
- `from`/`to`: explicitly bound the evaluation range.

---

## quantile

- **Nine** `type` options (1-9). Default `type = 7` (R default, linear interpolation). Type 1 = inverse of empirical CDF (SAS default). Types 4-9 are continuous; 1-3 are discontinuous.
- `na.rm = FALSE` by default — returns NA if any NAs present.
- `names = TRUE` by default, adding "0%", "25%", etc. as names.

---

## Distributions (gotchas across all)

All distribution functions follow the `d/p/q/r` pattern. Common non-obvious points:

- **`n` argument in `r*()` functions**: if `length(n) > 1`, uses `length(n)` as the count, not `n` itself. So `rnorm(c(1,2,3))` generates 3 values, not 1+2+3.
- `log = TRUE` / `log.p = TRUE`: compute on log scale for numerical stability in tails.
- `lower.tail = FALSE` gives survival function P(X > x) directly (more accurate than 1 - pnorm() in tails).
- **Gamma**: parameterized by `shape` and `rate` (= 1/scale). Default `rate = 1`. Specifying both `rate` and `scale` is an error.
- **Beta**: `shape1` (alpha), `shape2` (beta) — no `mean`/`sd` parameterization.
- **Poisson `dpois`**: `x` can be non-integer (returns 0 with a warning for non-integer values if `log = FALSE`).
- **Weibull**: `shape` and `scale` (no `rate`). R's parameterization: `f(x) = (shape/scale)(x/scale)^(shape-1) exp(-(x/scale)^shape)`.
- **Lognormal**: `meanlog` and `sdlog` are mean/sd of the **log**, not of the distribution itself.

---

## cor.test

- Default method: `"pearson"`. Also `"kendall"` and `"spearman"`.
- Returns `$estimate`, `$p.value`, `$conf.int` (CI only for Pearson).
- Formula interface: `cor.test(~ x + y, data = df)` — note the `~` with no LHS.

---

## ecdf

- Returns a **function** (step function). Call it on new values: `Fn <- ecdf(x); Fn(3.5)`.
- `plot(ecdf(x))` gives the empirical CDF plot.
- The returned function is right-continuous with left limits (cadlag).

---

## weighted.mean

- Handles `NA` in weights: observation is dropped if weight is `NA`.
- Weights do not need to sum to 1; they are normalized internally.
