

# shortcuts for running basic function on the current selection



#' xUnclass
#' Run desc() on selected text.
#' @export
xDesc <- function()  .execFunction("DescToolsX::desc")



#' xUnclass
#' Run head() on selected text.
#' @export
xUnclass <- function()  .execFunction("unclass")


#' xHead
#' Run head() on selected text.
#' @export
xHead <- function()  .execFunction("head")


#' xStrX
#' Run strX() on selected text.
#' @export
xStrX <- function()  .execFunction("bedrock::strX")


#' xAbstract
#' Run abstract() on selected text.
#' @export
xAbstract <- function()  .execFunction("DescToolsX::abstract")



#' xSummary
#' Run summary() on selected text.
#' @export
xSummary <- function()  .execFunction("summary")



#' xExample
#' Run example() on selected text.
#' @export
xExample <- function()  .execFunction("example")




# == internal helper functions =================================================

.execFunction <- function(FUN) {
  
  if (!rstudioapi::isAvailable()) {
    stop("RStudio API not available.")
  }
  
  sel <- rstudioapi::getActiveDocumentContext()$
    selection[[1]]$text
  
  if (nzchar(sel)) {
    rstudioapi::sendToConsole(
      sprintf("%s(%s)", FUN, sel),
      execute = TRUE,
      focus = FALSE
    )
  } else {
    message("No selection!")
  }
}

