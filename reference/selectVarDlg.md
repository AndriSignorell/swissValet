# Interactive variable selection dialog

Opens an interactive selection dialog and returns an expression that can
directly be used in R code.

## Usage

``` r
selectVarDlg(x, ...)

# Default S3 method
selectVarDlg(x, useIndex = FALSE, ...)

# S3 method for class 'numeric'
selectVarDlg(x, ...)

# S3 method for class 'factor'
selectVarDlg(x, ...)

# S3 method for class 'character'
selectVarDlg(x, ...)

# S3 method for class 'data.frame'
selectVarDlg(x, ...)
```

## Arguments

- x:

  An R object.

- ...:

  Additional arguments passed to methods.

- useIndex:

  Logical. Should indices instead of values be returned? Only used for
  the default method.

## Value

Invisibly returns a character string containing the generated R
expression.

## Details

Depending on the input type, different expressions are generated:

\- vectors: \`c(...)\` - numeric vectors: index selection -
factors/characters: \` - data frames: column selection

The generated expression is automatically copied to the clipboard.

The function uses \[utils::select.list()\] with \`graphics = TRUE\` for
interactive selection.

If no selection is made, an empty string is returned.

## Examples

``` r
if (FALSE) { # \dontrun{

# Character vector
selectVarDlg(letters)

# Numeric vector
selectVarDlg(1:10)

# Factor
selectVarDlg(factor(c("A", "B", "C")))

# Data frame columns
selectVarDlg(mtcars)

} # }
```
