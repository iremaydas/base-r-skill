# ============================================================
# Analysis Template — Base R
# Copy this file, rename it, and fill in your details.
# ============================================================
# Author  : 
# Date    : 
# Data    : 
# Purpose : 
# ============================================================


# ── 0. Setup ─────────────────────────────────────────────────
# Clear environment (optional — comment out if loading into existing session)
rm(list = ls())

# Set working directory if needed
# setwd("/path/to/your/project")

# Reproducibility
set.seed(42)

# Libraries — uncomment what you need
# library(haven)        # read .dta / .sav / .sas
# library(readxl)       # read Excel files
# library(openxlsx)     # write Excel files
# library(foreign)      # older Stata / SPSS formats
# library(survey)       # survey-weighted analysis
# library(lmtest)       # Breusch-Pagan, Durbin-Watson etc.
# library(sandwich)     # robust standard errors
# library(car)          # Type II/III ANOVA, VIF


# ── 1. Load Data ─────────────────────────────────────────────
df <- read.csv("your_data.csv", stringsAsFactors = FALSE)
# df <- readRDS("your_data.rds")
# df <- haven::read_dta("your_data.dta")

# First look — always run these
dim(df)
str(df)
head(df, 10)
summary(df)


# ── 2. Data Quality Check ────────────────────────────────────
# Missing values
na_report <- data.frame(
  column   = names(df),
  n_miss   = colSums(is.na(df)),
  pct_miss = round(colMeans(is.na(df)) * 100, 1),
  row.names = NULL
)
print(na_report[na_report$n_miss > 0, ])

# Duplicates
n_dup <- sum(duplicated(df))
cat(sprintf("Duplicate rows: %d\n", n_dup))

# Unique values for categorical columns
cat_cols <- names(df)[sapply(df, function(x) is.character(x) | is.factor(x))]
for (col in cat_cols) {
  cat(sprintf("\n%s (%d unique):\n", col, length(unique(df[[col]]))))
  print(table(df[[col]], useNA = "ifany"))
}


# ── 3. Clean & Transform ─────────────────────────────────────
# Rename columns (example)
# names(df)[names(df) == "old_name"] <- "new_name"

# Convert types
# df$group <- as.factor(df$group)
# df$date  <- as.Date(df$date, format = "%Y-%m-%d")

# Recode values (example)
# df$gender <- ifelse(df$gender == 1, "Male", "Female")

# Create new variables (example)
# df$log_income <- log(df$income + 1)
# df$age_group  <- cut(df$age,
#                      breaks = c(0, 25, 45, 65, Inf),
#                      labels = c("18-25", "26-45", "46-65", "65+"))

# Filter rows (example)
# df <- df[df$year >= 2010, ]
# df <- df[complete.cases(df[, c("outcome", "predictor")]), ]

# Drop unused factor levels
# df <- droplevels(df)


# ── 4. Descriptive Statistics ────────────────────────────────
# Numeric summary
num_cols <- names(df)[sapply(df, is.numeric)]
round(sapply(df[num_cols], function(x) c(
  n      = sum(!is.na(x)),
  mean   = mean(x, na.rm = TRUE),
  sd     = sd(x, na.rm = TRUE),
  median = median(x, na.rm = TRUE),
  min    = min(x, na.rm = TRUE),
  max    = max(x, na.rm = TRUE)
)), 3)

# Cross-tabulation
# table(df$group, df$category, useNA = "ifany")
# prop.table(table(df$group, df$category), margin = 1)  # row proportions


# ── 5. Visualization (EDA) ───────────────────────────────────
par(mfrow = c(2, 2))

# Histogram of main outcome
hist(df$outcome_var,
     main   = "Distribution of Outcome",
     xlab   = "Outcome",
     col    = "steelblue",
     border = "white",
     breaks = 30)

# Boxplot by group
boxplot(outcome_var ~ group_var,
        data = df,
        main = "Outcome by Group",
        col  = "lightyellow",
        las  = 2)

# Scatter plot
plot(df$predictor, df$outcome_var,
     main = "Predictor vs Outcome",
     xlab = "Predictor",
     ylab = "Outcome",
     pch  = 19,
     col  = adjustcolor("steelblue", alpha.f = 0.5),
     cex  = 0.8)
abline(lm(outcome_var ~ predictor, data = df),
       col = "red", lwd = 2)

# Correlation matrix (numeric columns only)
cor_mat <- cor(df[num_cols], use = "complete.obs")
image(cor_mat,
      main = "Correlation Matrix",
      col  = hcl.colors(20, "RdBu", rev = TRUE))

par(mfrow = c(1, 1))


# ── 6. Analysis ───────────────────────────────────────────────

# ·· 6a. Comparison of means ··
t.test(outcome_var ~ group_var, data = df)

# ·· 6b. Linear regression ··
fit <- lm(outcome_var ~ predictor1 + predictor2 + group_var,
          data = df)
summary(fit)
confint(fit)

# Check VIF for multicollinearity (requires car)
# car::vif(fit)

# Robust standard errors (requires lmtest + sandwich)
# lmtest::coeftest(fit, vcov = sandwich::vcovHC(fit, type = "HC3"))

# ·· 6c. ANOVA ··
# fit_aov <- aov(outcome_var ~ group_var, data = df)
# summary(fit_aov)
# TukeyHSD(fit_aov)

# ·· 6d. Logistic regression (binary outcome) ··
# fit_logit <- glm(binary_outcome ~ x1 + x2,
#                  data   = df,
#                  family = binomial(link = "logit"))
# summary(fit_logit)
# exp(coef(fit_logit))         # odds ratios
# exp(confint(fit_logit))      # OR confidence intervals


# ── 7. Model Diagnostics ─────────────────────────────────────
par(mfrow = c(2, 2))
plot(fit)
par(mfrow = c(1, 1))

# Residual normality
shapiro.test(residuals(fit))

# Homoscedasticity (requires lmtest)
# lmtest::bptest(fit)


# ── 8. Save Output ────────────────────────────────────────────
# Cleaned data
# write.csv(df, "data_clean.csv", row.names = FALSE)
# saveRDS(df, "data_clean.rds")

# Model results to text file
# sink("results.txt")
# cat("=== Linear Model ===\n")
# print(summary(fit))
# cat("\n=== Confidence Intervals ===\n")
# print(confint(fit))
# sink()

# Plots to file
# png("figure1_distributions.png", width = 1200, height = 900, res = 150)
# par(mfrow = c(2, 2))
# # ... your plots ...
# par(mfrow = c(1, 1))
# dev.off()

# ============================================================
# END OF TEMPLATE
# ============================================================
