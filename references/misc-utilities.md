# Miscellaneous Utilities — Quick Reference

> Non-obvious behaviors, gotchas, and tricky defaults for R functions.
> Only what Claude doesn't already know.

---

## do.call

- `do.call(fun, args_list)` — `args` must be a **list**, even for a single argument.
- `quote = TRUE` prevents evaluation of arguments before the call — needed when passing expressions/symbols.
- Behavior of `substitute` inside `do.call` differs from direct calls. Semantics are not fully defined for this case.
- Useful pattern: `do.call(rbind, list_of_dfs)` to combine a list of data frames.

---

## Reduce / Filter / Map / Find / Position

R's functional programming helpers from base — genuinely non-obvious.

- `Reduce(f, x)` applies binary function `f` cumulatively: `Reduce("+", 1:4)` = `((1+2)+3)+4`. Direction matters for non-commutative ops.
- `Reduce(f, x, accumulate = TRUE)` returns all intermediate results — equivalent to Python's `itertools.accumulate`.
- `Reduce(f, x, right = TRUE)` folds from the right: `f(x1, f(x2, f(x3, x4)))`.
- `Reduce` with `init` adds a starting value: `Reduce(f, x, init = v)` = `f(f(f(v, x1), x2), x3)`.
- `Filter(f, x)` keeps elements where `f(elem)` is `TRUE`. Unlike `x[sapply(x, f)]`, handles `NULL`/empty correctly.
- `Map(f, ...)` is a simple wrapper for `mapply(f, ..., SIMPLIFY = FALSE)` — always returns a list.
- `Find(f, x)` returns the **first** element where `f(elem)` is `TRUE`. `Find(f, x, right = TRUE)` for last.
- `Position(f, x)` returns the **index** of the first match (like `Find` but returns position, not value).

---

## lengths

- `lengths(x)` returns the length of **each element** of a list. Equivalent to `sapply(x, length)` but faster (implemented in C).
- Works on any list-like object. Returns integer vector.

---

## conditions (tryCatch / withCallingHandlers)

- `tryCatch` **unwinds** the call stack — handler runs in the calling environment, not where the error occurred. Cannot resume execution.
- `withCallingHandlers` does NOT unwind — handler runs where the condition was signaled. Can inspect/log then let the condition propagate.
- `tryCatch(expr, error = function(e) e)` returns the error condition object.
- `tryCatch(expr, warning = function(w) {...})` catches the **first** warning and exits. Use `withCallingHandlers` + `invokeRestart("muffleWarning")` to suppress warnings but continue.
- `tryCatch` `finally` clause always runs (like Java try/finally).
- `globalCallingHandlers()` registers handlers that persist for the session (useful for logging).
- Custom conditions: `stop(errorCondition("msg", class = "myError"))` then catch with `tryCatch(..., myError = function(e) ...)`.

---

## all.equal

- Tests **near equality** with tolerance (default `1.5e-8`, i.e., `sqrt(.Machine$double.eps)`).
- Returns `TRUE` or a **character string** describing the difference — NOT `FALSE`. Use `isTRUE(all.equal(x, y))` in conditionals.
- `tolerance` argument controls numeric tolerance. `scale` for absolute vs relative comparison.
- Checks attributes, names, dimensions — more thorough than `==`.

---

## combn

- `combn(n, m)` or `combn(x, m)`: generates all combinations of `m` items from `x`.
- Returns a **matrix** with `m` rows; each column is one combination.
- `FUN` argument applies a function to each combination: `combn(5, 3, sum)` returns sums of all 3-element subsets.
- `simplify = FALSE` returns a list instead of a matrix.

---

## modifyList

- `modifyList(x, val)` replaces elements of list `x` with those in `val` by **name**.
- Setting a value to `NULL` **removes** that element from the list.
- **Does** add new names not in `x` — it uses `x[names(val)] <- val` internally, so any name in `val` gets added or replaced.

---

## relist

- Inverse of `unlist`: given a flat vector and a skeleton list, reconstructs the nested structure.
- `relist(flesh, skeleton)` — `flesh` is the flat data, `skeleton` provides the shape.
- Works with factors, matrices, and nested lists.

---

## txtProgressBar

- `txtProgressBar(min, max, style = 3)` — style 3 shows percentage + bar (most useful).
- Update with `setTxtProgressBar(pb, value)`. Close with `close(pb)`.
- Style 1: rotating `|/-\`, style 2: simple progress. Only style 3 shows percentage.

---

## object.size

- Returns an **estimate** of memory used by an object. Not always exact for shared references.
- `format(object.size(x), units = "MB")` for human-readable output.
- Does not count the size of environments or external pointers.

---

## installed.packages / update.packages

- `installed.packages()` can be slow (scans all packages). Use `find.package()` or `requireNamespace()` to check for a specific package.
- `update.packages(ask = FALSE)` updates all packages without prompting.
- `lib.loc` specifies which library to check/update.

---

## vignette / demo

- `vignette()` lists all vignettes; `vignette("name", package = "pkg")` opens a specific one.
- `demo()` lists all demos; `demo("topic")` runs one interactively.
- `browseVignettes()` opens vignette browser in HTML.

---

## Time series: acf / arima / ts / stl / decompose

- `ts(data, start, frequency)`: `frequency` is observations per unit time (12 for monthly, 4 for quarterly).
- `acf` default `type = "correlation"`. Use `type = "partial"` for PACF. `plot = FALSE` to suppress auto-plotting.
- `arima(x, order = c(p,d,q))` for ARIMA models. `seasonal = list(order = c(P,D,Q), period = S)` for seasonal component.
- `arima` handles `NA` values in the time series (via Kalman filter).
- `stl` requires `s.window` (seasonal window) — must be specified, no default. `s.window = "periodic"` assumes fixed seasonality.
- `decompose`: simpler than `stl`, uses moving averages. `type = "additive"` or `"multiplicative"`.
- `stl` result components: `$time.series` matrix with columns `seasonal`, `trend`, `remainder`.
