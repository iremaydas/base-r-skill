#!/usr/bin/env Rscript
# scaffold_analysis.R — Generates a starter analysis script
#
# Usage (from terminal):
#   Rscript scaffold_analysis.R myproject
#   Rscript scaffold_analysis.R myproject outcome_var group_var
#
# Usage (from R console):
#   source("scaffold_analysis.R")
#   scaffold_analysis("myproject", outcome = "score", group = "treatment")
#
# Output: myproject_analysis.R  (ready to edit)

scaffold_analysis <- function(project_name,
                               outcome   = "outcome",
                               group     = "group",
                               data_file = NULL) {
  
  if (is.null(data_file)) data_file <- paste0(project_name, ".csv")
  out_file <- paste0(project_name, "_analysis.R")
  
  template <- sprintf(
'# ============================================================
# Project : %s
# Created : %s
# ============================================================

# ── 0. Libraries ─────────────────────────────────────────────
# Add packages you need here
# library(ggplot2)
# library(haven)     # for .dta files
# library(openxlsx)  # for Excel output


# ── 1. Load Data ─────────────────────────────────────────────
df <- read.csv("%s", stringsAsFactors = FALSE)

# Quick check — always do this first
cat("Dimensions:", dim(df), "\\n")
str(df)
head(df)


# ── 2. Explore / EDA ─────────────────────────────────────────
summary(df)

# NA check
na_counts <- colSums(is.na(df))
na_counts[na_counts > 0]

# Key variable distributions
hist(df$%s, main = "Distribution of %s", xlab = "%s")

if ("%s" %%in%% names(df)) {
  table(df$%s)
  barplot(table(df$%s),
          main = "Counts by %s",
          col  = "steelblue",
          las  = 2)
}


# ── 3. Clean / Transform ──────────────────────────────────────
# df <- df[complete.cases(df), ]        # drop rows with any NA
# df$%s <- as.factor(df$%s)            # convert to factor


# ── 4. Analysis ───────────────────────────────────────────────

# Descriptive stats by group
tapply(df$%s, df$%s, mean, na.rm = TRUE)
tapply(df$%s, df$%s, sd,   na.rm = TRUE)

# t-test (two groups)
# t.test(%s ~ %s, data = df)

# Linear model
fit <- lm(%s ~ %s, data = df)
summary(fit)
confint(fit)

# ANOVA (multiple groups)
# fit_aov <- aov(%s ~ %s, data = df)
# summary(fit_aov)
# TukeyHSD(fit_aov)


# ── 5. Visualize Results ──────────────────────────────────────
par(mfrow = c(1, 2))

# Boxplot by group
boxplot(%s ~ %s,
        data = df,
        main = "%s by %s",
        xlab = "%s",
        ylab = "%s",
        col  = "lightyellow")

# Model diagnostics
plot(fit, which = 1)  # residuals vs fitted

par(mfrow = c(1, 1))


# ── 6. Save Output ────────────────────────────────────────────
# Save cleaned data
# write.csv(df, "%s_clean.csv", row.names = FALSE)

# Save model summary to text
# sink("%s_results.txt")
# summary(fit)
# sink()

# Save plot to file
# png("%s_boxplot.png", width = 800, height = 600, res = 150)
# boxplot(%s ~ %s, data = df, col = "lightyellow")
# dev.off()
',
    project_name,
    format(Sys.Date(), "%%Y-%%m-%%d"),
    data_file,
    # Section 2 — EDA
    outcome, outcome, outcome,
    group, group, group, group,
    # Section 3
    group, group,
    # Section 4
    outcome, group,
    outcome, group,
    outcome, group,
    outcome, group,
    outcome, group,
    outcome, group,
    # Section 5
    outcome, group,
    outcome, group,
    group, outcome,
    # Section 6
    project_name, project_name, project_name,
    outcome, group
  )
  
  writeLines(template, out_file)
  cat(sprintf("Created: %s\n", out_file))
  invisible(out_file)
}


# ── Run from command line ─────────────────────────────────────
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) == 0) {
    cat("Usage: Rscript scaffold_analysis.R <project_name> [outcome_var] [group_var]\n")
    cat("Example: Rscript scaffold_analysis.R myproject score treatment\n")
    quit(status = 1)
  }
  
  project <- args[1]
  outcome <- if (length(args) >= 2) args[2] else "outcome"
  group   <- if (length(args) >= 3) args[3] else "group"
  
  scaffold_analysis(project, outcome = outcome, group = group)
}
