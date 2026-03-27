# Data Wrangling — Quick Reference

> Non-obvious behaviors, gotchas, and tricky defaults for R functions.
> Only what Claude doesn't already know.

---

## Extract / Extract.data.frame

Indexing pitfalls in base R.

- `m[j = 2, i = 1]` is `m[2, 1]` not `m[1, 2]` — argument names are **ignored** in `[`, positional matching only. Never name index args.
- Factor indexing: `x[f]` uses integer codes of factor `f`, not its character labels. Use `x[as.character(f)]` for label-based indexing.
- `x[[]]` with no index is always an error. `x$name` does partial matching by default; `x[["name"]]` does not (exact by default).
- Assigning `NULL` via `x[[i]] <- NULL` or `x$name <- NULL` **deletes** that list element.
- Data frame `[` with single column: `df[, 1]` returns a **vector** (drop=TRUE default for columns), but `df[1, ]` returns a **data frame** (drop=FALSE for rows). Use `drop = FALSE` explicitly.
- Matrix indexing a data frame (`df[cbind(i,j)]`) coerces to matrix first — avoid.

---

## subset

Use interactively only; unsafe for programming.

- `subset` argument uses **non-standard evaluation** — column names are resolved in the data frame, which can silently pick up wrong variables in programmatic use. Use `[` with explicit logic in functions.
- `NA`s in the logical condition are treated as `FALSE` (rows silently dropped).
- Factors may retain unused levels after subsetting; call `droplevels()`.

---

## match / %in%

- `%in%` **never returns NA** — this makes it safe for `if()` conditions unlike `==`.
- `match()` returns position of **first** match only; duplicates in `table` are ignored.
- Factors, raw vectors, and lists are all converted to character before matching.
- `NaN` matches `NaN` but not `NA`; `NA` matches `NA` only.

---

## apply

- On a **data frame**, `apply` coerces to matrix via `as.matrix` first — mixed types become character.
- Return value orientation is transposed: if FUN returns length-n vector, result has dim `c(n, dim(X)[MARGIN])`. Row results become **columns**.
- Factor results are coerced to character in the output array.
- `...` args cannot share names with `X`, `MARGIN`, or `FUN` (partial matching risk).

---

## lapply / sapply / vapply

- `sapply` can return a vector, matrix, or list unpredictably — use `vapply` in non-interactive code with explicit `FUN.VALUE` template.
- Calling primitives directly in `lapply` can cause dispatch issues; wrap in `function(x) is.numeric(x)` rather than bare `is.numeric`.
- `sapply` with `simplify = "array"` can produce higher-rank arrays (not just matrices).

---

## tapply

- Returns an **array** (not a data frame). Class info on return values is **discarded** (e.g., Date objects become numeric).
- `...` args to FUN are **not** divided into cells — they apply globally, so FUN should not expect additional args with same length as X.
- `default = NA` fills empty cells; set `default = 0` for sum-like operations. Before R 3.4.0 this was hard-coded to `NA`.
- Use `array2DF()` to convert result to a data frame.

---

## mapply

- Argument name is `SIMPLIFY` (all caps) not `simplify` — inconsistent with `sapply`.
- `MoreArgs` must be a **list** of args not vectorized over.
- Recycles shorter args to common length; zero-length arg gives zero-length result.

---

## merge

- Default `by` is `intersect(names(x), names(y))` — can silently merge on unintended columns if data frames share column names.
- `by = 0` or `by = "row.names"` merges on row names, adding a "Row.names" column.
- `by = NULL` (or both `by.x`/`by.y` length 0) produces **Cartesian product**.
- Result is sorted on `by` columns by default (`sort = TRUE`). For unsorted output use `sort = FALSE`.
- Duplicate key matches produce **all combinations** (one row per match pair).

---

## split

- If `f` is a list of factors, interaction is used; levels containing `"."` can cause unexpected splits unless `sep` is changed.
- `drop = FALSE` (default) retains empty factor levels as empty list elements.
- Supports formula syntax: `split(df, ~ Month)`.

---

## cbind / rbind

- `cbind` on data frames calls `data.frame(...)`, not `cbind.matrix`. Mixing matrices and data frames can give unexpected results.
- `rbind` on data frames matches columns **by name**, not position. Missing columns get `NA`.
- `cbind(NULL)` returns `NULL` (not a matrix). For consistency, `rbind(NULL)` also returns `NULL`.

---

## table

- By default **excludes NA** (`useNA = "no"`). Use `useNA = "ifany"` or `exclude = NULL` to count NAs.
- Setting `exclude` non-empty and non-default implies `useNA = "ifany"`.
- Result is always an **array** (even 1D), class "table". Convert to data frame with `as.data.frame(tbl)`.
- Two kinds of NA (factor-level NA vs actual NA) are treated differently depending on `useNA`/`exclude`.

---

## duplicated / unique

- `duplicated` marks the **second and later** occurrences as TRUE, not the first. Use `fromLast = TRUE` to reverse.
- For data frames, operates on whole rows. For lists, compares recursively.
- `unique` keeps the **first** occurrence of each value.

---

## data.frame (gotchas)

- `stringsAsFactors = FALSE` is the default since R 4.0.0 (was TRUE before).
- Atomic vectors recycle to match longest column, but only if exact multiple. Protect with `I()` to prevent conversion.
- Duplicate column names allowed only with `check.names = FALSE`, but many operations will de-dup them silently.
- Matrix arguments are expanded to multiple columns unless protected by `I()`.

---

## factor (gotchas)

- `as.numeric(f)` returns **integer codes**, not original values. Use `as.numeric(levels(f))[f]` or `as.numeric(as.character(f))`.
- Only `==` and `!=` work between factors; factors must have identical level sets. Ordered factors support `<`, `>`.
- `c()` on factors unions level sets (since R 4.1.0), but earlier versions converted to integer.
- Levels are sorted by default, but sort order is **locale-dependent** at creation time.

---

## aggregate

- Formula interface (`aggregate(y ~ x, data, FUN)`) drops `NA` groups by default.
- The data frame method requires `by` as a **list** (not a vector).
- Returns columns named after the grouping variables, with result column keeping the original name.
- If FUN returns multiple values, result column is a **matrix column** inside the data frame.

---

## complete.cases

- Returns a logical vector: TRUE for rows with **no** NAs across all columns/arguments.
- Works on multiple arguments (e.g., `complete.cases(x, y)` checks both).

---

## order

- Returns a **permutation vector** of indices, not the sorted values. Use `x[order(x)]` to sort.
- Default is ascending; use `-x` for descending numeric, or `decreasing = TRUE`.
- For character sorting, depends on locale. Use `method = "radix"` for locale-independent fast sorting.
- `sort.int()` with `method = "radix"` is much faster for large integer/character vectors.

