# Modeling — Quick Reference

> Non-obvious behaviors, gotchas, and tricky defaults for R functions.
> Only what Claude doesn't already know.

---

## formula

Symbolic model specification gotchas.

- `I()` is required to use arithmetic operators literally: `y ~ x + I(x^2)`. Without `I()`, `^` means interaction crossing.
- `*` = main effects + interaction: `a*b` expands to `a + b + a:b`.
- `(a+b+c)^2` = all main effects + all 2-way interactions (not squaring).
- `-` removes terms: `(a+b+c)^2 - a:b` drops only the `a:b` interaction.
- `/` means nesting: `a/b` = `a + b %in% a` = `a + a:b`.
- `.` in formula means "all other columns in data" (in `terms.formula` context) or "previous contents" (in `update.formula`).
- Formula objects carry an **environment** used for variable lookup; `as.formula("y ~ x")` uses `parent.frame()`.

---

## terms / model.matrix

- `model.matrix` creates the design matrix including dummy coding. Default contrasts: `contr.treatment` for unordered factors, `contr.poly` for ordered.
- `terms` object attributes: `order` (interaction order per term), `intercept`, `factors` matrix.
- Column names from `model.matrix` can be surprising: e.g., `factorLevelName` concatenation.

---

## glm

- Default `family = gaussian(link = "identity")` — `glm()` with no `family` silently fits OLS (same as `lm`, but slower and with deviance-based output).
- Common families: `binomial(link = "logit")`, `poisson(link = "log")`, `Gamma(link = "inverse")`, `inverse.gaussian()`.
- `binomial` accepts response as: 0/1 vector, logical, factor (second level = success), or 2-column matrix `cbind(success, failure)`.
- `weights` in `glm` means **prior weights** (not frequency weights) — for frequency weights, use the cbind trick or offset.
- `predict.glm(type = "response")` for predicted probabilities; default `type = "link"` returns log-odds (for logistic) or log-rate (for Poisson).
- `anova(glm_obj, test = "Chisq")` for deviance-based tests; `"F"` is invalid for non-Gaussian families.
- Quasi-families (`quasibinomial`, `quasipoisson`) allow overdispersion — no AIC is computed.
- Convergence: `control = glm.control(maxit = 100)` if default 25 iterations isn't enough.

---

## aov

- `aov` is a wrapper around `lm` that stores extra info for balanced ANOVA. For unbalanced designs, Type I SS (sequential) are computed — order of terms matters.
- For Type III SS, use `car::Anova()` or set contrasts to `contr.sum`/`contr.helmert`.
- Error strata for repeated measures: `aov(y ~ A*B + Error(Subject/B))`.
- `summary.aov` gives ANOVA table; `summary.lm(aov_obj)` gives regression-style summary.

---

## nls

- Requires **good starting values** in `start = list(...)` or convergence fails.
- Self-starting models (`SSlogis`, `SSasymp`, etc.) auto-compute starting values.
- Algorithm `"port"` allows bounds on parameters (`lower`/`upper`).
- If data fits too exactly (no residual noise), convergence check fails — use `control = list(scaleOffset = 1)` or jitter data.
- `weights` argument for weighted NLS; `na.action` for missing value handling.

---

## step / add1

- `step` does **stepwise** model selection by AIC (default). Use `k = log(n)` for BIC.
- Direction: `direction = "both"` (default), `"forward"`, or `"backward"`.
- `add1`/`drop1` evaluate single-term additions/deletions; `step` calls these iteratively.
- `scope` argument defines the upper/lower model bounds for search.
- `step` modifies the model object in place — can be slow for large models with many candidate terms.

---

## predict.lm / predict.glm

- `predict.lm` with `interval = "confidence"` gives CI for **mean** response; `interval = "prediction"` gives PI for **new observation** (wider).
- `newdata` must have columns matching the original formula variables — factors must have the same levels.
- `predict.glm` with `type = "response"` gives predictions on the response scale (e.g., probabilities for logistic); `type = "link"` (default) gives on the link scale.
- `se.fit = TRUE` returns standard errors; for `predict.glm` these are on the **link** scale regardless of `type`.
- `predict.lm` with `type = "terms"` returns the contribution of each term.

---

## loess

- `span` controls smoothness (default 0.75). Span < 1 uses that proportion of points; span > 1 uses all points with adjusted distance.
- Maximum **4 predictors**. Memory usage is roughly **quadratic** in n (1000 points ~ 10MB).
- `degree = 0` (local constant) is allowed but poorly tested — use with caution.
- Not identical to S's `loess`; conditioning is not implemented.
- `normalize = TRUE` (default) standardizes predictors to common scale; set `FALSE` for spatial coords.

---

## lowess vs loess

- `lowess` is the older function; returns `list(x, y)` — cannot predict at new points.
- `loess` is the newer formula interface with `predict` method.
- `lowess` parameter is `f` (span, default 2/3); `loess` parameter is `span` (default 0.75).
- `lowess` `iter` default is 3 (robustifying iterations); `loess` default `family = "gaussian"` (no robustness).

---

## smooth.spline

- Default smoothing parameter selected by **GCV** (generalized cross-validation).
- `cv = TRUE` uses ordinary leave-one-out CV instead — do not use with duplicate x values.
- `spar` and `lambda` control smoothness; `df` can specify equivalent degrees of freedom.
- Returns object with `predict`, `print`, `plot` methods. The `fit` component has knots and coefficients.

---

## optim

- **Minimizes** by default. To maximize: set `control = list(fnscale = -1)`.
- Default method is Nelder-Mead (no gradients, robust but slow). Poor for 1D — use `"Brent"` or `optimize()`.
- `"L-BFGS-B"` is the only method supporting box constraints (`lower`/`upper`). Bounds auto-select this method with a warning.
- `"SANN"` (simulated annealing): convergence code is **always 0** — it never "fails". `maxit` = total function evals (default 10000), no other stopping criterion.
- `parscale`: scale parameters so unit change in each produces comparable objective change. Critical for mixed-scale problems.
- `hessian = TRUE`: returns numerical Hessian of the **unconstrained** problem even if box constraints are active.
- `fn` can return `NA`/`Inf` (except `"L-BFGS-B"` which requires finite values always). Initial value must be finite.

---

## optimize / uniroot

- `optimize`: 1D minimization on a bounded interval. Returns `minimum` and `objective`.
- `uniroot`: finds a root of `f` in `[lower, upper]`. **Requires** `f(lower)` and `f(upper)` to have opposite signs.
- `uniroot` with `extendInt = "yes"` can auto-extend the interval to find sign change — but can find spurious roots for functions that don't actually cross zero.
- `nlm`: Newton-type minimizer. Gradient/Hessian as **attributes** of the return value from `fn` (unusual interface).

---

## TukeyHSD

- Requires a fitted `aov` object (not `lm`).
- Default `conf.level = 0.95`. Returns adjusted p-values and confidence intervals for all pairwise comparisons.
- Only meaningful for **balanced** or near-balanced designs; can be liberal for very unbalanced data.

---

## anova (for lm)

- `anova(model)`: sequential (Type I) SS — **order of terms matters**.
- `anova(model1, model2)`: F-test comparing nested models.
- For Type II or III SS use `car::Anova()`.
