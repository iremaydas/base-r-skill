# Dates and System — Quick Reference

> Non-obvious behaviors, gotchas, and tricky defaults for R functions.
> Only what Claude doesn't already know.

---

## Dates (Date class)

- `Date` objects are stored as **integer days since 1970-01-01**. Arithmetic works in days.
- `Sys.Date()` returns current date as Date object.
- `seq.Date(from, to, by = "month")` — "month" increments can produce varying-length intervals. Adding 1 month to Jan 31 gives Mar 3 (not Feb 28).
- `diff(dates)` returns a `difftime` object in days.
- `format(date, "%Y")` for year, `"%m"` for month, `"%d"` for day, `"%A"` for weekday name (locale-dependent).
- Years before 1CE may not be handled correctly.
- `length(date_vector) <- n` pads with `NA`s if extended.

---

## DateTimeClasses (POSIXct / POSIXlt)

- `POSIXct`: seconds since 1970-01-01 UTC (compact, a numeric vector).
- `POSIXlt`: list with components `$sec`, `$min`, `$hour`, `$mday`, `$mon` (0-11!), `$year` (since 1900!), `$wday` (0-6, Sunday=0), `$yday` (0-365).
- Converting between POSIXct and Date: `as.Date(posixct_obj)` uses `tz = "UTC"` by default — may give different date than intended if original was in another timezone.
- `Sys.time()` returns POSIXct in current timezone.
- `strptime` returns POSIXlt; `as.POSIXct(strptime(...))` to get POSIXct.
- `difftime` arithmetic: subtracting POSIXct objects gives difftime. Units auto-selected ("secs", "mins", "hours", "days", "weeks").

---

## difftime

- `difftime(time1, time2, units = "auto")` — auto-selects smallest sensible unit.
- Explicit units: `"secs"`, `"mins"`, `"hours"`, `"days"`, `"weeks"`. No "months" or "years" (variable length).
- `as.numeric(diff, units = "hours")` to extract numeric value in specific units.
- `units(diff_obj) <- "hours"` changes the unit in place.

---

## system.time / proc.time

- `system.time(expr)` returns `user`, `system`, and `elapsed` time.
- `gcFirst = TRUE` (default): runs garbage collection before timing for more consistent results.
- `proc.time()` returns cumulative time since R started — take differences for intervals.
- `elapsed` (wall clock) can be less than `user` (multi-threaded BLAS) or more (I/O waits).

---

## Sys.sleep

- `Sys.sleep(seconds)` — allows fractional seconds. Actual sleep may be longer (OS scheduling).
- The process **yields** to the OS during sleep (does not busy-wait).

---

## options (key options)

Selected non-obvious options:

- `options(scipen = n)`: positive biases toward fixed notation, negative toward scientific. Default 0. Applies to `print`/`format`/`cat` but not `sprintf`.
- `options(digits = n)`: significant digits for printing (1-22, default 7). Suggestion only.
- `options(digits.secs = n)`: max decimal digits for seconds in time formatting (0-6, default 0).
- `options(warn = n)`: -1 = ignore warnings, 0 = collect (default), 1 = immediate, 2 = convert to errors.
- `options(error = recover)`: drop into debugger on error. `options(error = NULL)` resets to default.
- `options(OutDec = ",")`: change decimal separator in output (affects `format`, `print`, NOT `sprintf`).
- `options(stringsAsFactors = FALSE)`: global default for `data.frame` (moot since R 4.0.0 where it's already FALSE).
- `options(expressions = 5000)`: max nested evaluations. Increase for deep recursion.
- `options(max.print = 99999)`: controls truncation in `print` output.
- `options(na.action = "na.omit")`: default NA handling in model functions.
- `options(contrasts = c("contr.treatment", "contr.poly"))`: default contrasts for unordered/ordered factors.

---

## file.path / basename / dirname

- `file.path("a", "b", "c.txt")` → `"a/b/c.txt"` (platform-appropriate separator).
- `basename("/a/b/c.txt")` → `"c.txt"`. `dirname("/a/b/c.txt")` → `"/a/b"`.
- `file.path` does NOT normalize paths (no `..` resolution); use `normalizePath()` for that.

---

## list.files

- `list.files(pattern = "*.csv")` — `pattern` is a **regex**, not a glob! Use `glob2rx("*.csv")` or `"\\.csv$"`.
- `full.names = FALSE` (default) returns basenames only. Use `full.names = TRUE` for complete paths.
- `recursive = TRUE` to search subdirectories.
- `all.files = TRUE` to include hidden files (starting with `.`).

---

## file.info

- Returns data frame with `size`, `isdir`, `mode`, `mtime`, `ctime`, `atime`, `uid`, `gid`.
- `mtime`: modification time (POSIXct). Useful for `file.info(f)$mtime`.
- On some filesystems, `ctime` is status-change time, not creation time.

---

## file_test

- `file_test("-f", path)`: TRUE if regular file exists.
- `file_test("-d", path)`: TRUE if directory exists.
- `file_test("-nt", f1, f2)`: TRUE if f1 is newer than f2.
- More reliable than `file.exists()` for distinguishing files from directories.
