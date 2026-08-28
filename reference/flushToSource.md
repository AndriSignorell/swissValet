# Insert selected object as reproducible R code

Converts the currently selected object in the RStudio editor into
reproducible R source code and inserts it into the active document.

## Usage

``` r
flushToSource(width.cutoff = 500L)
```

## Arguments

- width.cutoff:

  Integer. Passed to \[base::deparse()\].

## Value

Invisibly returns the generated code.

## Details

Data frames are converted into a readable \`data.frame(...)\`
representation instead of the more verbose \`dput()\` structure output.

Other objects are serialized using \[base::dput()\].

## Examples

``` r
if (FALSE) { # \dontrun{
flushToSource()
} # }
```
