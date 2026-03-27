# Visualization — Quick Reference

> Non-obvious behaviors, gotchas, and tricky defaults for R functions.
> Only what Claude doesn't already know.

---

## par (gotchas)

- `par()` settings are per-device. Opening a new device resets everything.
- Setting `mfrow`/`mfcol` resets `cex` to 1 and `mex` to 1. With 2x2 layout, base `cex` is multiplied by 0.83; with 3+ rows/columns, by 0.66.
- `mai` (inches), `mar` (lines), `pin`, `plt`, `pty` all interact. Restoring all saved parameters after device resize can produce inconsistent results — last-alphabetically wins.
- `bg` set via `par()` also sets `new = FALSE`. Setting `fg` via `par()` also sets `col`.
- `xpd = NA` clips to device region (allows drawing in outer margins); `xpd = TRUE` clips to figure region; `xpd = FALSE` (default) clips to plot region.
- `mgp = c(3, 1, 0)`: controls title line (`mgp[1]`), label line (`mgp[2]`), axis line (`mgp[3]`). All in `mex` units.
- `las`: 0 = parallel to axis, 1 = horizontal, 2 = perpendicular, 3 = vertical. Does **not** respond to `srt`.
- `tck = 1` draws grid lines across the plot. `tcl = -0.5` (default) gives outward ticks.
- `usr` with log scale: contains **log10** of the coordinate limits, not the raw values.
- Read-only parameters: `cin`, `cra`, `csi`, `cxy`, `din`, `page`.

---

## layout

- `layout(mat)` where `mat` is a matrix of integers specifying figure arrangement.
- `widths`/`heights` accept `lcm()` for absolute sizes mixed with relative sizes.
- More flexible than `mfrow`/`mfcol` but cannot be queried once set (unlike `par("mfrow")`).
- `layout.show(n)` visualizes the layout for debugging.

---

## axis / mtext

- `axis(side, at, labels)`: `side` 1=bottom, 2=left, 3=top, 4=right.
- Default gap between axis labels controlled by `par("mgp")`. Labels can overlap if not managed.
- `mtext`: `line` argument positions text in margin lines (0 = adjacent to plot, positive = outward). `adj` controls horizontal position (0-1).
- `mtext` with `outer = TRUE` writes in the **outer** margin (set by `par(oma = ...)`).

---

## curve

- First argument can be an **expression** in `x` or a function: `curve(sin, 0, 2*pi)` or `curve(x^2 + 1, 0, 10)`.
- `add = TRUE` to overlay on existing plot. Default `n = 101` evaluation points.
- `xname = "x"` by default; change if your expression uses a different variable name.

---

## pairs

- `panel` function receives `(x, y, ...)` for each pair. `lower.panel`, `upper.panel`, `diag.panel` for different regions.
- `gap` controls spacing between panels (default 1).
- Formula interface: `pairs(~ var1 + var2 + var3, data = df)`.

---

## coplot

- Conditioning plots: `coplot(y ~ x | a)` or `coplot(y ~ x | a * b)` for two conditioning variables.
- `panel` function can be customized; `rows`/`columns` control layout.
- Default panel draws points; use `panel = panel.smooth` for loess overlay.

---

## matplot / matlines / matpoints

- Plots columns of one matrix against columns of another. Recycles `col`, `lty`, `pch` across columns.
- `type = "l"` by default (unlike `plot` which defaults to `"p"`).
- Useful for plotting multiple time series or fitted curves simultaneously.

---

## contour / filled.contour / image

- `contour(x, y, z)`: `z` must be a matrix with `dim = c(length(x), length(y))`.
- `filled.contour` has a non-standard layout — it creates its own plot region for the color key. **Cannot use `par(mfrow)` with it**. Adding elements requires the `plot.axes` argument.
- `image`: plots z-values as colored rectangles. Default color scheme may be misleading; set `col` explicitly.
- For `image`, `x` and `y` specify **cell boundaries** or **midpoints** depending on context.

---

## persp

- `persp(x, y, z, theta, phi)`: `theta` = azimuthal angle, `phi` = colatitude.
- Returns a **transformation matrix** (invisible) for projecting 3D to 2D — use `trans3d()` to add points/lines to the perspective plot.
- `shade` and `col` control surface shading. `border = NA` removes grid lines.

---

## segments / arrows / rect / polygon

- All take vectorized coordinates; recycle as needed.
- `arrows`: `code = 1` (head at start), `code = 2` (head at end, default), `code = 3` (both).
- `polygon`: last point auto-connects to first. Fill with `col`; `border` controls outline.
- `rect(xleft, ybottom, xright, ytop)` — note argument order is not the same as other systems.

---

## dev / dev.off / dev.copy

- `dev.new()` opens a new device. `dev.off()` closes current device (and flushes output for file devices like `pdf`).
- `dev.off()` on the **last** open device reverts to null device.
- `dev.copy(pdf, file = "plot.pdf")` followed by `dev.off()` to save current plot.
- `dev.list()` returns all open devices; `dev.cur()` the active one.

---

## pdf

- Must call `dev.off()` to finalize the file. Without it, file may be empty/corrupt.
- `onefile = TRUE` (default): multiple pages in one PDF. `onefile = FALSE`: one file per page (uses `%d` in filename for numbering).
- `useDingbats = FALSE` recommended to avoid issues with certain PDF viewers and pch symbols.
- Default size: 7x7 inches. `family` controls font family.

---

## png / bitmap devices

- `res` controls DPI (default 72). For publication: `res = 300` with appropriate `width`/`height` in pixels or inches (with `units = "in"`).
- `type = "cairo"` (on systems with cairo) gives better antialiasing than default.
- `bg = "transparent"` for transparent background (PNG supports alpha).

---

## colors / rgb / hcl / col2rgb

- `colors()` returns all 657 named colors. `col2rgb("color")` returns RGB matrix.
- `rgb(r, g, b, alpha, maxColorValue = 255)` — note `maxColorValue` default is 1, not 255.
- `hcl(h, c, l)`: perceptually uniform color space. Preferred for color scales.
- `adjustcolor(col, alpha.f = 0.5)`: easy way to add transparency.

---

## colorRamp / colorRampPalette

- `colorRamp` returns a **function** mapping [0,1] to RGB matrix.
- `colorRampPalette` returns a **function** taking `n` and returning `n` interpolated colors.
- `space = "Lab"` gives more perceptually uniform interpolation than `"rgb"`.

---

## palette / recordPlot

- `palette()` returns current palette (default 8 colors). `palette("Set1")` sets a built-in palette.
- Integer colors in plots index into the palette (with wrapping). Index 0 = background color.
- `recordPlot()` / `replayPlot()`: save and restore a complete plot — device-dependent and fragile across sessions.
