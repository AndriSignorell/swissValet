
#' Escape Unicode Characters
#'
#' Converts non-ASCII characters to Unicode escape sequences.
#'
#' @param x a character vector
#'
#' @return a character vector containing Unicode escape sequences
#'
#' @examples
#' escapeUnicode("Schneeh\u00f6he")
#' unescapeUnicode("Schneeh\\u00f6he")
#'
#' @export
escapeUnicode <- function(x) {
  
  x <- as.character(x)
  
  vapply(
    x,
    function(value) {
      
      if (is.na(value))
        return(NA_character_)
      
      code <- utf8ToInt(enc2utf8(value))
      chars <- intToUtf8(code, multiple = TRUE)
      
      bmp <- code > 0x7f & code <= 0xffff
      supplementary <- code > 0xffff
      
      chars[bmp] <- sprintf("\\u%04x", code[bmp])
      chars[supplementary] <- sprintf("\\U%08x", code[supplementary])
      
      paste0(chars, collapse = "")
    },
    character(1),
    USE.NAMES = TRUE
  )
}


#' Unescape Unicode Characters
#'
#' Converts Unicode escape sequences to their corresponding characters.
#'
#' @inheritParams escapeUnicode
#'
#' @return a character vector containing decoded Unicode characters
#'
#' @examples
#' unescapeUnicode("Schneeh\\u00f6he")
#'
#' @export
unescapeUnicode <- function(x) {
  
  x <- as.character(x)
  valid <- !is.na(x)
  
  if (!any(valid))
    return(x)
  
  pattern <- "\\\\(?:u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})"
  
  text <- x[valid]
  matches <- gregexpr(pattern, text, perl = TRUE)
  escapes <- regmatches(text, matches)
  
  replacements <- lapply(
    escapes,
    function(value) {
      
      if (!length(value))
        return(value)
      
      code <- strtoi(
        sub("^\\\\[uU]", "", value),
        base = 16L
      )
      
      isValid <- !is.na(code) &
        code <= 0x10ffff &
        !(code >= 0xd800 & code <= 0xdfff)
      
      value[isValid] <- intToUtf8(
        code[isValid],
        multiple = TRUE
      )
      
      value
    }
  )
  
  regmatches(text, matches) <- replacements
  x[valid] <- text
  
  x
}



#' Unicode RStudio Addins
#'
#' Converts Unicode characters or escape sequences in the selected text.
#'
#' @return `NULL`, invisibly
#'
#' @name unicodeAddins
NULL

#' @rdname unicodeAddins
#' @export
toggleUnicodeAddin <- function() {
  
  .transformUnicodeSelection(
    function(text) {
      
      pattern <- "\\\\(?:u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})"
      
      hasEscapes <- grepl(pattern, text, perl = TRUE)
      
      text[hasEscapes] <- unescapeUnicode(text[hasEscapes])
      text[!hasEscapes] <- escapeUnicode(text[!hasEscapes])
      
      text
    }
  )
}


# == internal helper functions ==============================================

.selectionEnd <- function(start, text) {
  
  lineBreaks <- gregexpr("\n", text, fixed = TRUE)[[1L]]
  
  if (lineBreaks[[1L]] == -1L) {
    
    return(
      rstudioapi::document_position(
        row = start[["row"]],
        column = start[["column"]] + nchar(text, type = "chars")
      )
    )
  }
  
  lastBreak <- lineBreaks[[length(lineBreaks)]]
  lastLine <- substring(text, lastBreak + 1L)
  
  rstudioapi::document_position(
    row = start[["row"]] + length(lineBreaks),
    column = nchar(lastLine, type = "chars") + 1L
  )
}


.transformUnicodeSelection <- function(transform) {
  
  if (!rstudioapi::isAvailable())
    stop("This function must be called from RStudio.", call. = FALSE)
  
  context <- rstudioapi::getActiveDocumentContext()
  selections <- context$selection
  
  text <- vapply(
    selections,
    function(selection) selection$text,
    character(1)
  )
  
  selected <- nzchar(text)
  
  if (!any(selected))
    stop("No text is selected.", call. = FALSE)
  
  selections <- selections[selected]
  text <- text[selected]
  
  startRows <- vapply(
    selections,
    function(selection) selection$range$start[["row"]],
    numeric(1)
  )
  
  startColumns <- vapply(
    selections,
    function(selection) selection$range$start[["column"]],
    numeric(1)
  )
  
  orderSelection <- order(startRows, startColumns)
  selections <- selections[orderSelection]
  text <- text[orderSelection]
  
  newRanges <- vector("list", length(selections))
  columnShift <- numeric()
  
  for (i in seq_along(selections)) {
    
    range <- selections[[i]]$range
    start <- range$start
    end <- range$end
    
    startRow <- as.character(start[["row"]])
    endRow <- as.character(end[["row"]])
    
    startShift <- columnShift[startRow]
    
    if (!length(startShift) || is.na(startShift))
      startShift <- 0
    
    endShift <- columnShift[endRow]
    
    if (!length(endShift) || is.na(endShift))
      endShift <- 0
    
    start <- rstudioapi::document_position(
      row = start[["row"]],
      column = start[["column"]] + startShift
    )
    
    end <- rstudioapi::document_position(
      row = end[["row"]],
      column = end[["column"]] + endShift
    )
    
    replacement <- transform(text[[i]])
    
    currentRange <- rstudioapi::document_range(start, end)
    
    rstudioapi::modifyRange(
      location = currentRange,
      text = replacement,
      id = context$id
    )
    
    newEnd <- .selectionEnd(start, replacement)
    newRanges[[i]] <- rstudioapi::document_range(start, newEnd)
    
    change <- newEnd[["column"]] - end[["column"]]
    
    oldShift <- columnShift[endRow]
    
    if (!length(oldShift) || is.na(oldShift))
      oldShift <- 0
    
    columnShift[endRow] <- oldShift + change
  }
  
  rstudioapi::setSelectionRanges(
    ranges = newRanges,
    id = context$id
  )
  
  invisible(NULL)
}



