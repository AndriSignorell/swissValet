# Random subset of an object

Returns a random subset of observations/elements from vectors, matrices,
and data frames.

## Usage

``` r
some(x, n = 6L, ...)

# S3 method for class 'data.frame'
some(x, n = 6L, ...)

# S3 method for class 'matrix'
some(x, n = 6L, addrownums = TRUE, ...)

# Default S3 method
some(x, n = 6L, ...)
```

## Arguments

- x:

  An R object.

- n:

  Integer scalar specifying the number of elements or rows to return.
  Defaults to \`6L\`. Negative values reduce the total number of
  returned elements relative to the object size.

- ...:

  Additional arguments passed to methods.

- addrownums:

  Logical. Should artificial row names be added for matrices without row
  names? Only used for matrices.

## Value

A random subset of \`x\`.

\- For vectors: a vector. - For matrices: a matrix. - For data frames: a
data frame.

## Details

Negative values of \`n\` are interpreted as:

\`length(x) + n\`

or

\`nrow(x) + n\`

respectively.

This function is useful for quickly inspecting random parts of larger
objects.

## Examples

``` r
some(1:100)
#> [1] 23 31 45 47 63 76

some(letters, 10)
#>  [1] "b" "d" "e" "f" "i" "k" "m" "o" "r" "w"

some(mtcars, 5)
#>                    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4 Wag     21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
#> Hornet Sportabout 18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
#> Merc 450SE        16.4   8 275.8 180 3.07 4.070 17.40  0  0    3    3
#> Toyota Corona     21.5   4 120.1  97 3.70 2.465 20.01  1  0    3    1
#> Ford Pantera L    15.8   8 351.0 264 4.22 3.170 14.50  0  1    5    4

some(as.matrix(mtcars), 4)
#>                      mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> Hornet 4 Drive      21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> Valiant             18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
#> Lincoln Continental 10.4   8  460 215 3.00 5.424 17.82  0  0    3    4
#> Maserati Bora       15.0   8  301 335 3.54 3.570 14.60  0  1    5    8

# Negative n
some(1:20, -5)
#>  [1]  1  2  3  4  5  6  7  9 10 11 12 14 15 16 20
```
