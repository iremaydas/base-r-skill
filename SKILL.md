---
name: base-r
description: Provides base R programming guidance covering data structures, data wrangling, statistical modeling, visualization, and I/O — using only packages included in a standard R installation. Use when the user writes or debugs R scripts, works with vectors, matrices, lists, data frames, or factors, applies the apply family (sapply, lapply, vapply, tapply), fits models with lm/glm/aov/nls, creates base graphics with plot/barplot/hist/boxplot/par, reads or writes CSV/RDS/RData files, or asks about R language semantics such as environments, scoping, and non-standard evaluation. Also use for R statistical functions (t.test, chisq.test, cor, kmeans, prcomp), string operations, date handling, and file system utilities. Do not use for tidyverse workflows (dplyr, tidyr, purrr), ggplot2, data.table, Shiny, R package development, Rcpp, or Python/Julia/Stata tasks.
---

# Base R Programming Skill

A comprehensive reference for base R programming — covering data structures, control flow, functions, I/O, statistical computing, and plotting.

## Quick Reference

### Data Structures

```r
# Vectors (atomic)
x <- c(1, 2, 3)              # numeric
y <- c("a", "b", "c")        # character
z <- c(TRUE, FALSE, TRUE)    # logical

# Factor
f <- factor(c("low", "med", "high"), levels = c("low", "med", "high"), ordered = TRUE)

# Matrix
m <- matrix(1:6, nrow = 2, ncol = 3)
m[1, ]       # first row
m[, 2]       # second column

# List
lst <- list(name = "ali", scores = c(90, 85), passed = TRUE)
lst$name      # access by name
lst[[2]]      # access by position

# Data frame
df <- data.frame(
  id = 1:3,
  name = c("a", "b", "c"),
  value = c(10.5, 20.3, 30.1),
  stringsAsFactors = FALSE
)
df[df$value > 15, ]    # filter rows
df$new_col <- df$value * 2  # add column
```

### Subsetting

```r
# Vectors
x[1:3]             # by position
x[c(TRUE, FALSE)]  # by logical
x[x > 5]           # by condition
x[-1]              # exclude first

# Data frames
df[1:5, ]                    # first 5 rows
df[, c("name", "value")]     # select columns
df[df$value > 10, "name"]    # filter + select
subset(df, value > 10, select = c(name, value))

# which() for index positions
idx <- which(df$value == max(df$value))
```

### Control Flow

```r
# if/else
if (x > 0) {
  "positive"
} else if (x == 0) {
  "zero"
} else {
  "negative"
}

# ifelse (vectorized)
ifelse(x > 0, "pos", "neg")

# for loop
for (i in seq_along(x)) {
  cat(i, x[i], "\n")
}

# while
while (condition) {
  # body
  if (stop_cond) break
}

# switch
switch(type,
  "a" = do_a(),
  "b" = do_b(),
  stop("Unknown type")
)
```

### Functions

```r
# Define
my_func <- function(x, y = 1, ...) {
  result <- x + y
  return(result)  # or just: result
}

# Anonymous functions
sapply(1:5, function(x) x^2)
# R 4.1+ shorthand:
sapply(1:5, \(x) x^2)

# Useful: do.call for calling with a list of args
do.call(paste, list("a", "b", sep = "-"))
```

### Apply Family

```r
# sapply — simplify result to vector/matrix
sapply(lst, length)

# lapply — always returns list
lapply(lst, function(x) x[1])

# vapply — like sapply but with type safety
vapply(lst, length, integer(1))

# apply — over matrix margins (1=rows, 2=cols)
apply(m, 2, sum)

# tapply — apply by groups
tapply(df$value, df$group, mean)

# mapply — multivariate
mapply(function(x, y) x + y, 1:3, 4:6)

# aggregate — like tapply for data frames
aggregate(value ~ group, data = df, FUN = mean)
```

### String Operations

```r
paste("a", "b", sep = "-")    # "a-b"
paste0("x", 1:3)              # "x1" "x2" "x3"
sprintf("%.2f%%", 3.14159)    # "3.14%"
nchar("hello")                # 5
substr("hello", 1, 3)         # "hel"
gsub("old", "new", text)      # replace all
grep("pattern", x)            # indices of matches
grepl("pattern", x)           # logical vector
strsplit("a,b,c", ",")        # list("a","b","c")
trimws("  hi  ")              # "hi"
tolower("ABC")                # "abc"
```

### Data I/O

```r
# CSV
df <- read.csv("data.csv", stringsAsFactors = FALSE)
write.csv(df, "output.csv", row.names = FALSE)

# Tab-delimited
df <- read.delim("data.tsv")

# General
df <- read.table("data.txt", header = TRUE, sep = "\t")

# RDS (single R object, preserves types)
saveRDS(obj, "data.rds")
obj <- readRDS("data.rds")

# RData (multiple objects)
save(df1, df2, file = "data.RData")
load("data.RData")

# Connections
con <- file("big.csv", "r")
chunk <- readLines(con, n = 100)
close(con)
```

### Base Plotting

```r
# Scatter
plot(x, y, main = "Title", xlab = "X", ylab = "Y",
     pch = 19, col = "steelblue", cex = 1.2)

# Line
plot(x, y, type = "l", lwd = 2, col = "red")
lines(x, y2, col = "blue", lty = 2)  # add line

# Bar
barplot(table(df$category), main = "Counts",
        col = "lightblue", las = 2)

# Histogram
hist(x, breaks = 30, col = "grey80",
     main = "Distribution", xlab = "Value")

# Box plot
boxplot(value ~ group, data = df,
        col = "lightyellow", main = "By Group")

# Multiple plots
par(mfrow = c(2, 2))  # 2x2 grid
# ... four plots ...
par(mfrow = c(1, 1))  # reset

# Save to file
png("plot.png", width = 800, height = 600)
plot(x, y)
dev.off()

# Add elements
legend("topright", legend = c("A", "B"),
       col = c("red", "blue"), lty = 1)
abline(h = 0, lty = 2, col = "grey")
text(x, y, labels = names, pos = 3, cex = 0.8)
```

### Statistics

```r
# Descriptive
mean(x); median(x); sd(x); var(x)
quantile(x, probs = c(0.25, 0.5, 0.75))
summary(df)
cor(x, y)
table(df$category)  # frequency table

# Linear model
fit <- lm(y ~ x1 + x2, data = df)
summary(fit)
coef(fit)
predict(fit, newdata = new_df)
confint(fit)

# t-test
t.test(x, y)                    # two-sample
t.test(x, mu = 0)               # one-sample
t.test(before, after, paired = TRUE)

# Chi-square
chisq.test(table(df$a, df$b))

# ANOVA
fit <- aov(value ~ group, data = df)
summary(fit)
TukeyHSD(fit)

# Correlation test
cor.test(x, y, method = "pearson")
```

### Data Manipulation

```r
# Merge (join)
merged <- merge(df1, df2, by = "id")                  # inner
merged <- merge(df1, df2, by = "id", all = TRUE)      # full outer
merged <- merge(df1, df2, by = "id", all.x = TRUE)    # left

# Reshape
wide <- reshape(long, direction = "wide",
                idvar = "id", timevar = "time", v.names = "value")
long <- reshape(wide, direction = "long",
                varying = list(c("v1", "v2")), v.names = "value")

# Sort
df[order(df$value), ]              # ascending
df[order(-df$value), ]             # descending
df[order(df$group, -df$value), ]   # multi-column

# Remove duplicates
df[!duplicated(df), ]
df[!duplicated(df$id), ]

# Stack / combine
rbind(df1, df2)    # stack rows (same columns)
cbind(df1, df2)    # bind columns (same rows)

# Transform columns
df$log_val <- log(df$value)
df$category <- cut(df$value, breaks = c(0, 10, 20, Inf),
                   labels = c("low", "med", "high"))
```

### Environment & Debugging

```r
ls()                  # list objects
rm(x)                 # remove object
rm(list = ls())       # clear all
str(obj)              # structure
class(obj)            # class
typeof(obj)           # internal type
is.na(x)              # check NA
complete.cases(df)    # rows without NA
traceback()           # after error
debug(my_func)        # step through
browser()             # breakpoint in code
system.time(expr)     # timing
Sys.time()            # current time
```

## Reference Files

For deeper coverage, read the reference files in `references/`:

### Function Gotchas & Quick Reference (condensed from R 4.5.3 Reference Manual)
Non-obvious behaviors, surprising defaults, and tricky interactions — only what Claude doesn't already know:
- **data-wrangling.md** — Read when: subsetting returns wrong type, apply on data frame gives unexpected coercion, merge/split/cbind behaves oddly, factor levels persist after filtering, table/duplicated edge cases.
- **modeling.md** — Read when: formula syntax is confusing (`I()`, `*` vs `:`, `/`), aov gives wrong SS type, glm silently fits OLS, nls won't converge, predict returns wrong scale, optim/optimize needs tuning.
- **statistics.md** — Read when: hypothesis test gives surprising result, need to choose correct p.adjust method, clustering parameters seem wrong, distribution function naming is confusing (`d`/`p`/`q`/`r` prefixes).
- **visualization.md** — Read when: par settings reset unexpectedly, layout/mfrow interaction is confusing, axis labels are clipped, colors don't look right, need specialty plots (contour, persp, mosaic, pairs).
- **io-and-text.md** — Read when: read.table silently drops data or misparses columns, regex behaves differently than expected, sprintf formatting is tricky, write.table output has unwanted row names.
- **dates-and-system.md** — Read when: Date/POSIXct conversion gives wrong day, time zones cause off-by-one, difftime units are unexpected, need to find/list/test files programmatically.
- **misc-utilities.md** — Read when: do.call behaves differently than direct call, need Reduce/Filter/Map, tryCatch handler doesn't fire, all.equal returns string not logical, time series functions need setup.

## Tips for Writing Good R Code

- Use `vapply()` over `sapply()` in production code — it enforces return types
- Prefer `seq_along(x)` over `1:length(x)` — the latter breaks when `x` is empty
- Use `stringsAsFactors = FALSE` in `read.csv()` / `data.frame()` (default changed in R 4.0)
- Vectorize operations instead of writing loops when possible
- Use `stop()`, `warning()`, `message()` for error handling — not `print()`
- `<<-` assigns to parent environment — use sparingly and intentionally
- `with(df, expr)` avoids repeating `df$` everywhere
- `Sys.setenv()` and `.Renviron` for environment variables
