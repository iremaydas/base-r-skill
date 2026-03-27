# I/O and Text Processing — Quick Reference

> Non-obvious behaviors, gotchas, and tricky defaults for R functions.
> Only what Claude doesn't already know.

---

## read.table (gotchas)

- `sep = ""` (default) means **any whitespace** (spaces, tabs, newlines) — not a literal empty string.
- `comment.char = "#"` by default — lines with `#` are truncated. Use `comment.char = ""` to disable (also faster).
- `header` auto-detection: set to TRUE if first row has **one fewer field** than subsequent rows (the missing field is assumed to be row names).
- `colClasses = "NULL"` **skips** that column entirely — very useful for speed.
- `read.csv` defaults differ from `read.table`: `header = TRUE`, `sep = ","`, `fill = TRUE`, `comment.char = ""`.
- For large files: specifying `colClasses` and `nrows` dramatically reduces memory usage. `read.table` is slow for wide data frames (hundreds of columns); use `scan` or `data.table::fread` for matrices.
- `stringsAsFactors = FALSE` since R 4.0.0 (was TRUE before).

---

## write.table (gotchas)

- `row.names = TRUE` by default — produces an unnamed first column that confuses re-reading. Use `row.names = FALSE` or `col.names = NA` for Excel-compatible CSV.
- `write.csv` fixes `sep = ","`, `dec = "."`, and uses `qmethod = "double"` — cannot override these via `...`.
- `quote = TRUE` (default) quotes character/factor columns. Numeric columns are never quoted.
- Matrix-like columns in data frames expand to multiple columns silently.
- Slow for data frames with many columns (hundreds+); each column processed separately by class.

---

## read.fwf

- Reads fixed-width format files. `widths` is a vector of field widths.
- **Negative widths skip** that many characters (useful for ignoring fields).
- `buffersize` controls how many lines are read at a time; increase for large files.
- Uses `read.table` internally after splitting fields.

---

## count.fields

- Counts fields per line in a file — useful for diagnosing read errors.
- `sep` and `quote` arguments match those of `read.table`.

---

## grep / grepl / sub / gsub (gotchas)

- Three regex modes: POSIX extended (default), `perl = TRUE`, `fixed = TRUE`. They behave differently for edge cases.
- **Name arguments explicitly** — unnamed args after `x`/`pattern` are matched positionally to `ignore.case`, `perl`, etc. Common source of silent bugs.
- `sub` replaces **first** match only; `gsub` replaces **all** matches.
- Backreferences: `"\\1"` in replacement (double backslash in R strings). With `perl = TRUE`: `"\\U\\1"` for uppercase conversion.
- `grep(value = TRUE)` returns matching **elements**; `grep(value = FALSE)` (default) returns **indices**.
- `grepl` returns logical vector — preferred for filtering.
- `regexpr` returns first match position + length (as attributes); `gregexpr` returns all matches as a list.
- `regexec` returns match + capture group positions; `gregexec` does this for all matches.
- Character classes like `[:alpha:]` must be inside `[[:alpha:]]` (double brackets) in POSIX mode.

---

## strsplit

- Returns a **list** (one element per input string), even for a single string.
- `split = ""` or `split = character(0)` splits into individual characters.
- Match at beginning of string: first element of result is `""`. Match at end: no trailing `""`.
- `fixed = TRUE` is faster and avoids regex interpretation.
- Common mistake: unnamed arguments silently match `fixed`, `perl`, etc.

---

## substr / substring

- `substr(x, start, stop)`: extracts/replaces substring. 1-indexed, inclusive on both ends.
- `substring(x, first, last)`: same but `last` defaults to `1000000L` (effectively "to end"). Vectorized over `first`/`last`.
- Assignment form: `substr(x, 1, 3) <- "abc"` replaces in place (must be same length replacement).

---

## trimws

- `which = "both"` (default), `"left"`, or `"right"`.
- `whitespace = "[ \\t\\r\\n]"` — customizable regex for what counts as whitespace.

---

## nchar

- `type = "bytes"` counts bytes; `type = "chars"` (default) counts characters; `type = "width"` counts display width.
- `nchar(NA)` returns `NA` (not 2). `nchar(factor)` works on the level labels.
- `keepNA = TRUE` (default since R 3.3.0); set to `FALSE` to count `"NA"` as 2 characters.

---

## format / formatC

- `format(x, digits, nsmall)`: `nsmall` forces minimum decimal places. `big.mark = ","` adds thousands separator.
- `formatC(x, format = "f", digits = 2)`: C-style formatting. `format = "e"` for scientific, `"g"` for general.
- `format` returns character vector; always right-justified by default (`justify = "right"`).

---

## type.convert

- Converts character vectors to appropriate types (logical, integer, double, complex, character).
- `as.is = TRUE` (recommended): keeps characters as character, not factor.
- Applied column-wise on data frames. `tryLogical = TRUE` (R 4.3+) converts "TRUE"/"FALSE" columns.

---

## Rscript

- `commandArgs(trailingOnly = TRUE)` gets script arguments (excluding R/Rscript flags).
- `#!` line on Unix: `/usr/bin/env Rscript` or full path.
- `--vanilla` or `--no-init-file` to skip `.Rprofile` loading.
- Exit code: `quit(status = 1)` for error exit.

---

## capture.output

- Captures output from `cat`, `print`, or any expression that writes to stdout.
- `file = NULL` (default) returns character vector. `file = "out.txt"` writes directly to file.
- `type = "message"` captures stderr instead.

---

## URLencode / URLdecode

- `URLencode(url, reserved = FALSE)` by default does NOT encode reserved chars (`/`, `?`, `&`, etc.).
- Set `reserved = TRUE` to encode a URL **component** (query parameter value).

---

## glob2rx

- Converts shell glob patterns to regex: `glob2rx("*.csv")` → `"^.*\\.csv$"`.
- Useful with `list.files(pattern = glob2rx("data_*.RDS"))`.
