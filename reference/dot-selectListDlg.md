# Tcl/Tk selection dialog

Lightweight replacement for \`utils::select.list()\` with improved
spacing and keyboard handling.

## Usage

``` r
.selectListDlg(x, title = "Select one or more", multiple = TRUE)
```

## Arguments

- x:

  Character vector of selectable items.

- title:

  Window title.

- multiple:

  Logical. Allow multiple selection?

## Value

Character vector of selected items. Returns \`character(0)\` if
cancelled.
