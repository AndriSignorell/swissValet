
#' Random subset of an object
#'
#' Returns a random subset of observations/elements from vectors,
#' matrices, and data frames.
#'
#' Negative values of `n` are interpreted as:
#'
#' `length(x) + n`
#'
#' or
#'
#' `nrow(x) + n`
#'
#' respectively.
#'
#' This function is useful for quickly inspecting random parts of
#' larger objects.
#' 
#' @name some
#' @param x An R object.
#' @param n Integer scalar specifying the number of elements or rows
#'   to return. Defaults to `6L`.
#'   Negative values reduce the total number of returned elements
#'   relative to the object size.
#' @param addrownums Logical. Should artificial row names be added
#'   for matrices without row names? Only used for matrices.
#' @param ... Additional arguments passed to methods.
#'
#' @return
#' A random subset of `x`.
#'
#' - For vectors: a vector.
#' - For matrices: a matrix.
#' - For data frames: a data frame.
#'
#' @examples
#' some(1:100)
#'
#' some(letters, 10)
#'
#' some(mtcars, 5)
#'
#' some(as.matrix(mtcars), 4)
#'
#' # Negative n
#' some(1:20, -5)
#'

#' @export
some <- function(x, n = 6L, ...){
  UseMethod("some")
}


#' @rdname some
#' @export
some.data.frame <- function (x, n = 6L, ...) {
  stopifnot(length(n) == 1L)
  n <- if (n < 0L)
    max(nrow(x) + n, 0L)
  else min(n, nrow(x))
  x[sort(sample(nrow(x), n)), , drop = FALSE]
}


#' @rdname some
#' @export
some.matrix <- function (x, n = 6L, addrownums = TRUE, ...) {
  
  stopifnot(length(n) == 1L)
  nrx <- nrow(x)
  n <- if (n < 0L)
    max(nrx + n, 0L)
  else min(n, nrx)
  sel <- sort(sample(nrow(x), n))
  ans <- x[sel, , drop = FALSE]
  if (addrownums && is.null(rownames(x)))
    rownames(ans) <- format(sprintf("[%d,]", sel), justify = "right")
  ans
}


#' @rdname some
#' @export
some.default <- function (x, n = 6L, ...) {
  stopifnot(length(n) == 1L)
  n <- if (n < 0L)
    max(length(x) + n, 0L)
  else min(n, length(x))
  x[sort(sample(length(x), n))]
}

