

removeDuplicates <- function () {
  
  rng <- rstudioapi::getActiveDocumentContext()
  txt <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if (txt != "") {
    
    txt <- strsplit(txt, split = "\n")[[1]]
    u <- unique(txt)
    utxt <- paste(u, collapse = "\n")
    # add the last cr if the original already had it
    if(length(grep("\\n$", txt))!=0)
      utxt <- paste0(utxt, "\n")
    
    rstudioapi::modifyRange(utxt)
    
    sel <- rng$selection[[1]]$range
    sel$end[1] <- sel$end[1] - (length(txt) - length(u))
    
    rstudioapi::setSelectionRanges(sel)
    
    note <- gettextf("\033[36m\nNote: ------\n  %s duplicates have been found and removed. %s values remain.\n\n\033[39m", 
                     length(txt) - length(u), length(u)) 
    cat(note)
    
  }
  else {
    cat("No selection!\n")
  }
}

