# base-r-skill 

A [Claude Code](https://claude.ai/code) skill for base R programming.

---

## The Story

I'm a political science PhD candidate who uses R regularly but would never call myself *an R person*. I needed a Claude Code skill for base R — something without tidyverse, without ggplot2, just plain R — and I couldn't find one anywhere.

So I made one myself. At 11pm. Asking Claude to help me build a skill for Claude. 

If you're also someone who Googles `how to drop NA rows in R` every single time, this one's for you. 🫶

---

## What's Inside

```
base-r/
├── SKILL.md                    # Main skill file
├── references/                 # Gotchas & non-obvious behaviors
│   ├── data-wrangling.md       # Subsetting traps, apply family, merge, factor quirks
│   ├── modeling.md             # Formula syntax, lm/glm/aov/nls, optim
│   ├── statistics.md           # Hypothesis tests, distributions, clustering
│   ├── visualization.md        # par, layout, devices, colors
│   ├── io-and-text.md          # read.table, grep, regex, format
│   ├── dates-and-system.md     # Date/POSIXct traps, options(), file ops
│   └── misc-utilities.md       # tryCatch, do.call, time series, utilities
├── scripts/
│   ├── check_data.R            # Quick data quality report for any data frame
│   └── scaffold_analysis.R     # Generates a starter analysis script
└── assets/
    └── analysis_template.R     # Copy-paste analysis template
```

The reference files were condensed from the official R 4.5.3 manual — **19,518 lines → 945 lines** (95% reduction). Only the non-obvious stuff survived: gotchas, surprising defaults, tricky interactions. The things Claude already knows well got cut.

---

## How to Use

Add this skill to your Claude Code setup by pointing to this repo. Then Claude will automatically load the relevant reference files when you're working on R tasks.

Works best for:
- Base R data manipulation (no tidyverse)
- Statistical modeling with `lm`, `glm`, `aov`
- Base graphics with `plot`, `par`, `barplot`
- Understanding why your R code is doing that weird thing

Not for: tidyverse, ggplot2, Shiny, or R package development.

---

## The `check_data.R` Script

Probably the most useful standalone thing here. Source it and run `check_data(df)` on any data frame to get a formatted report of dimensions, NA counts, numeric summaries, and categorical breakdowns.

```r
source("scripts/check_data.R")
check_data(your_df)
```

---

## Built With Help From

- Claude (obviously)
- The official R manuals (all 19,518 lines of them)
- Mild frustration and several cups of coffee

---

## Contributing

If you spot a missing gotcha, a wrong default, or something that should be in the references — PRs are very welcome. I'm learning too.

---

*Made by [@iremaydas](https://github.com/iremaydas) — PhD candidate, occasional R user, full-time Googler of things I should probably know by now.*
