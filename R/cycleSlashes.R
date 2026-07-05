


cycleSlashes <- function() {

  rng <- rstudioapi::getActiveDocumentContext()
  txt <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  
  if(txt != "") {
    txt <- .normalize_and_cycle(txt)
    len <- nchar(txt)
    
    rstudioapi::modifyRange(txt)
    rng <- rng$selection[[1]]$range
    rng[["end"]][2] <- rng[["start"]][2] + len
    rstudioapi::setSelectionRanges(rng)
    
  } else {
    cat("No selection!\n")
  }
  
}



# == internal helper functions ===========================================

.normalize_and_cycle <- function(x) {
  
  # Normalize mixed separators first
  n_back <- nchar(x) - nchar(gsub("\\\\", "", x))
  n_fwd  <- nchar(x) - nchar(gsub("/", "", x))
  
  if (n_back > 0 && n_fwd > 0) {
    if (n_fwd >= n_back) {
      x <- gsub("\\\\", "/", x)
    } else {
      x <- gsub("/", "\\\\", x)
    }
  }
  
  # Cycle: \\ -> /  ->  // -> \ -> \\
  if (grepl("//", x, fixed = TRUE)) {
    gsub("//", "\\", x, fixed = TRUE)
  } else if (grepl("/", x, fixed = TRUE)) {
    gsub("/", "//", x, fixed = TRUE)
  } else if (grepl("\\\\", x, fixed = TRUE)) {
    gsub("\\\\", "/", x, fixed = TRUE)
  } else {
    gsub("\\", "\\\\", x, fixed = TRUE)
  }
  
}
