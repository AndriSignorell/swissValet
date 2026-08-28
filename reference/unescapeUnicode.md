# Unescape Unicode Characters

Converts Unicode escape sequences to their corresponding characters.

## Usage

``` r
unescapeUnicode(x)
```

## Arguments

- x:

  a character vector

## Value

a character vector containing decoded Unicode characters

## Examples

``` r
unescapeUnicode("Schneeh\\u00f6he")
#> [1] "Schneehöhe"
```
