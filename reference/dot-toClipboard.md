# Write text to clipboard

Cross-platform clipboard helper using the clipr package.

## Usage

``` r
.toClipboard(x, sep = "\n", warn = FALSE)
```

## Arguments

- x:

  Object to write to the clipboard. Will be collapsed with \`sep\`.

- sep:

  Character string used to collapse \`x\`.

- warn:

  Logical. Should clipboard failures generate a warning?

## Value

Invisibly returns \`TRUE\` on success and \`FALSE\` otherwise.

## Details

The function fails silently in non-interactive sessions or when
clipboard access is unavailable.
