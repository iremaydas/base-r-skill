# check_data.R — Quick data quality report for any R data frame
# Usage: source("check_data.R") then call check_data(df)
# Or:    source("check_data.R"); check_data(read.csv("yourfile.csv"))

check_data <- function(df, top_n_levels = 8) {
  
  if (!is.data.frame(df)) stop("Input must be a data frame.")
  
  n_row <- nrow(df)
  n_col <- ncol(df)
  
  cat("══════════════════════════════════════════\n")
  cat("  DATA QUALITY REPORT\n")
  cat("══════════════════════════════════════════\n")
  cat(sprintf("  Rows: %d    Columns: %d\n", n_row, n_col))
  cat("══════════════════════════════════════════\n\n")
  
  # ── 1. Column overview ──────────────────────
  cat("── COLUMN OVERVIEW ────────────────────────\n")
  
  for (col in names(df)) {
    x     <- df[[col]]
    cls   <- class(x)[1]
    n_na  <- sum(is.na(x))
    pct   <- round(n_na / n_row * 100, 1)
    n_uniq <- length(unique(x[!is.na(x)]))
    
    na_flag <- if (n_na == 0) "" else sprintf("  *** %d NAs (%.1f%%)", n_na, pct)
    cat(sprintf("  %-20s  %-12s  %d unique%s\n",
                col, cls, n_uniq, na_flag))
  }
  
  # ── 2. NA summary ────────────────────────────
  cat("\n── NA SUMMARY ─────────────────────────────\n")
  
  na_counts <- sapply(df, function(x) sum(is.na(x)))
  cols_with_na <- na_counts[na_counts > 0]
  
  if (length(cols_with_na) == 0) {
    cat("  No missing values. \n")
  } else {
    cat(sprintf("  Columns with NAs: %d of %d\n\n", length(cols_with_na), n_col))
    for (col in names(cols_with_na)) {
      bar_len  <- round(cols_with_na[col] / n_row * 20)
      bar      <- paste0(rep("█", bar_len), collapse = "")
      pct_na   <- round(cols_with_na[col] / n_row * 100, 1)
      cat(sprintf("  %-20s  [%-20s]  %d (%.1f%%)\n",
                  col, bar, cols_with_na[col], pct_na))
    }
  }
  
  # ── 3. Numeric columns ───────────────────────
  num_cols <- names(df)[sapply(df, is.numeric)]
  
  if (length(num_cols) > 0) {
    cat("\n── NUMERIC COLUMNS ────────────────────────\n")
    cat(sprintf("  %-20s  %8s  %8s  %8s  %8s  %8s\n",
                "Column", "Min", "Mean", "Median", "Max", "SD"))
    cat(sprintf("  %-20s  %8s  %8s  %8s  %8s  %8s\n",
                "──────", "───", "────", "──────", "───", "──"))
    
    for (col in num_cols) {
      x  <- df[[col]][!is.na(df[[col]])]
      if (length(x) == 0) next
      cat(sprintf("  %-20s  %8.3g  %8.3g  %8.3g  %8.3g  %8.3g\n",
                  col,
                  min(x), mean(x), median(x), max(x), sd(x)))
    }
  }
  
  # ── 4. Factor / character columns ───────────
  cat_cols <- names(df)[sapply(df, function(x) is.factor(x) | is.character(x))]
  
  if (length(cat_cols) > 0) {
    cat("\n── CATEGORICAL COLUMNS ────────────────────\n")
    
    for (col in cat_cols) {
      x    <- df[[col]]
      tbl  <- sort(table(x, useNA = "no"), decreasing = TRUE)
      n_lv <- length(tbl)
      cat(sprintf("\n  %s  (%d unique values)\n", col, n_lv))
      
      show <- min(top_n_levels, n_lv)
      for (i in seq_len(show)) {
        lbl <- names(tbl)[i]
        cnt <- tbl[i]
        pct <- round(cnt / n_row * 100, 1)
        cat(sprintf("    %-25s  %5d  (%.1f%%)\n", lbl, cnt, pct))
      }
      if (n_lv > top_n_levels) {
        cat(sprintf("    ... and %d more levels\n", n_lv - top_n_levels))
      }
    }
  }
  
  # ── 5. Duplicate rows ────────────────────────
  cat("\n── DUPLICATES ─────────────────────────────\n")
  n_dup <- sum(duplicated(df))
  if (n_dup == 0) {
    cat("  No duplicate rows.\n")
  } else {
    cat(sprintf("  %d duplicate row(s) found (%.1f%% of data)\n",
                n_dup, n_dup / n_row * 100))
  }
  
  cat("\n══════════════════════════════════════════\n")
  cat("  END OF REPORT\n")
  cat("══════════════════════════════════════════\n")
  
  # Return invisibly for programmatic use
  invisible(list(
    dims       = c(rows = n_row, cols = n_col),
    na_counts  = na_counts,
    n_dupes    = n_dup
  ))
}
