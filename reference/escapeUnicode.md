# Escape Unicode Characters

Converts non-ASCII characters to Unicode escape sequences.

## Usage

``` r
escapeUnicode(x)
```

## Arguments

- x:

  a character vector

## Value

a character vector containing Unicode escape sequences

## Examples

``` r
escapeUnicode("Schneeh\u00f6he")
#>         Schneehöhe 
#> "Schneeh\\u00f6he" 
unescapeUnicode("Schneeh\\u00f6he")
#> [1] "Schneehöhe"
```
