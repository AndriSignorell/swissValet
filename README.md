# swissValet

<img src="man/figures/logo.png" align="right" width="120"/>

<!-- badges: start -->
[![R-CMD-check](https://github.com/AndriSignorell/swissValet/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AndriSignorell/swissValet/actions)
[![License: GPL (>=2)](https://img.shields.io/badge/license-GPL%20(%3E%3D%202)-blue.svg)](https://www.gnu.org/licenses/gpl-2.0.html)
<!-- badges: end -->

`swissValet` is a collection of interactive RStudio helper functions and addins designed to reduce friction during daily data analysis work.

The package focuses on:

- fast inspection of objects
- interactive code generation
- editor utilities
- plotting helpers
- reproducible snippets
- keyboard-driven workflows
- small ergonomic improvements for RStudio

Most functions operate directly on the current editor selection and are intended to be assigned to keyboard shortcuts.

---

## Installation

```r
remotes::install_github("AndriSignorell/swissValet")
```

---

# Philosophy

`swissValet` is intentionally pragmatic.

The package contains many small utilities that save:

- keystrokes
- context switching
- repetitive typing
- clipboard juggling
- temporary objects

Most functions are designed for interactive use inside RStudio.

---

# Recommended Setup

The package becomes significantly more useful when functions are mapped to keyboard shortcuts.

In RStudio:

```text
Tools
→ Modify Keyboard Shortcuts
```

Typical examples:

| Shortcut | Function |
|---|---|
| Ctrl+Shift+S | `xStrX()` |
| Ctrl+Shift+H | `xHead()` |
| Ctrl+Shift+D | `xDesc()` |
| Ctrl+Shift+P | `Plot()` |
| Ctrl+Shift+L | `sortLines()` |

---

# Main Features

## Interactive Object Inspection

Quickly inspect selected objects from the editor.

```r
xHead()
xSummary()
xStrX()
xDesc()
xUnclass()
xExample()
```

These functions automatically use the currently selected text in the editor and execute the corresponding command.

---

## Better `str()`

`strX()` extends `str()` with numbered variables and cleaner output.

```r
strX(mtcars)
```

Useful for:

- large data frames
- quick orientation
- teaching
- screenshots
- debugging

---

## Random Sampling

```r
some(mtcars)
some(letters, 10)
some(1:100, -5)
```

Convenient random subsets for:

- exploration
- testing
- examples
- debugging

---

## Interactive Variable Selection

```r
selectVarDlg(mtcars)
```

Interactive selection dialog returning ready-to-use R expressions.

Examples:

```r
c("mpg","hp","wt")
```

```r
mtcars[, c("mpg","hp")]
```

```r
x %in% c("A","B")
```

---

## Build Model Formulas Interactively

```r
buildModel()
```

Opens a graphical model builder for regression formulas.

Features:

- interactive variable selection
- interactions
- polynomial terms
- formula editing
- keyboard shortcuts
- automatic model code generation

---

## Reproducible Object Export

```r
flushToSource()
```

Converts selected objects into reproducible source code and inserts them into the editor.

Data frames are rendered as readable:

```r
data.frame(...)
```

instead of verbose `dput(structure(...))`.

---

## Line Utilities

```r
SortAsc()
SortDesc()
Shuffle()
sortLines()
```

Sort or shuffle selected editor lines interactively.

---

## File Helpers

```r
FileOpen()
fileSaveAs()
FileImport()
FileBrowserOpen()
```

Convenience wrappers for:

- opening files
- importing data
- exporting objects
- generating reproducible file paths

---

## Plotting Helpers

```r
Plot()
PlotD()
PlotPar()
PlotMar()
SavePlot()
```

Small utilities for faster plotting workflows.

---

## Color & Symbol Pickers

```r
ColorDlg()
colPicker()
pchPicker()
```

Interactive graphical pickers for:

- colors
- plotting symbols
- graphical parameters

---

# Tcl/Tk Dialog System

The package contains a growing collection of custom Tcl/Tk dialogs:

- centered windows
- keyboard navigation
- ESC/Enter support
- clipboard integration
- modernized layouts
- reusable helper infrastructure

Examples:

- `.selectListDlg()`
- `.orderSelectionDlg()`
- `.modelDlg()`

---

# Clipboard Integration

Many functions automatically copy generated expressions to the clipboard.

Clipboard support uses the modern `clipr` package and fails gracefully on unsupported systems.

---

# Example Workflow

Select text in the editor:

```r
mtcars
```

Press shortcut assigned to:

```r
xStrX()
```

Result:

```r
strX(mtcars)
```

is immediately executed in the console.

---

# Dependencies

`swissValet` builds upon:

- `rstudioapi`
- `tcltk`
- `clipr`
- `cli`
- `writexl`
- `bedrock`
- `aurora`
- `DescToolsX`

---

# Status

`swissValet` is under active development and intentionally experimental in parts.

The package prioritizes:

- interactive ergonomics
- speed
- convenience
- developer productivity

over strict API stability.

---

# Author

Andri Signorell

---

# License

GPL (>= 2)

---

# Links

- GitHub: https://github.com/AndriSignorell/swissValet
- Issues: https://github.com/AndriSignorell/swissValet/issues
