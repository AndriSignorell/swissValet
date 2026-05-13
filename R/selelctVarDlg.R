
#' Interactive variable selection dialog
#'
#' Opens an interactive selection dialog and returns an expression
#' that can directly be used in R code.
#'
#' Depending on the input type, different expressions are generated:
#'
#' - vectors: `c(...)`
#' - numeric vectors: index selection
#' - factors/characters: `%in%`
#' - data frames: column selection
#'
#' The generated expression is automatically copied to the clipboard.
#'
#' @name selectVarDlg
#' @param x An R object.
#' @param useIndex Logical. Should indices instead of values be returned?
#'   Only used for the default method.
#' @param ... Additional arguments passed to methods.
#'
#' @return
#' Invisibly returns a character string containing the generated
#' R expression.
#'
#' @details
#' The function uses [utils::select.list()] with
#' `graphics = TRUE` for interactive selection.
#'
#' If no selection is made, an empty string is returned.
#'
#' @examples
#' \dontrun{
#'
#' # Character vector
#' selectVarDlg(letters)
#'
#' # Numeric vector
#' selectVarDlg(1:10)
#'
#' # Factor
#' selectVarDlg(factor(c("A", "B", "C")))
#'
#' # Data frame columns
#' selectVarDlg(mtcars)
#'
#' }
#'


#' @export
selectVarDlg <- function (x, ...) {
  UseMethod("selectVarDlg")
}


#' @rdname selectVarDlg
#' @export
selectVarDlg.default <- function(x, useIndex = FALSE, ...){
  
  # example: Sel(d.pizza)
  xsel <- select.list(x, multiple = TRUE, graphics = TRUE)
  if(useIndex == TRUE) {
    xsel <- which(x %in% xsel)
  } else {
    xsel <- shQuote(xsel)
  }
  
  if(!identical(xsel, "\"\""))
    txt <- paste("c(", paste(xsel, collapse=","),")", sep="")
  else
    txt <- ""
  
  .ToClipboard(txt)
  
  invisible(txt)
}


#' @rdname selectVarDlg
#' @export
selectVarDlg.numeric <- function(x, ...) {
  
  if(!is.null(names(x)))
    z <- names(x)
  else
    z <- as.character(x)
  
  txt <- paste(deparse(substitute(x)), "[", selectVarDlg.default( x = z, ...), "]",
               sep="", collapse="")
  .ToClipboard(txt)
  
  invisible(txt)
  
}


#' @rdname selectVarDlg
#' @export
selectVarDlg.factor <- function(x, ...) {
  
  sel <- selectVarDlg.default( x = levels(x), ...)
  if(sel!="")
    txt <- paste(deparse(substitute(x)), " %in% ",
                 sel, sep="", collapse="")
  else
    txt <- ""
  
  .ToClipboard(txt)
  
  invisible(txt)
}


#' @rdname selectVarDlg
#' @export
selectVarDlg.character <- function(x, ...) {
  
  sel <- selectVarDlg.default( x = unique(x), ...)
  if(sel!="")
    txt <- paste(deparse(substitute(x)), " %in% ",
                 sel, sep="", collapse="")
  else
    txt <- ""
  
  .ToClipboard(txt)
  
  invisible(txt)
}



#' @rdname selectVarDlg
#' @export
selectVarDlg.data.frame <- function(x, ...) {
  
  sel <- selectVarDlg.default( x = colnames(x), ...)
  
  if(sel!="" && sel!="c()"){
    txt <- paste(deparse(substitute(x)), "[,",
                 sel, "]", sep="", collapse="")
    
    .ToClipboard(txt)
    
  } else {
    txt <- ""
  }
  
  invisible(txt)
}

