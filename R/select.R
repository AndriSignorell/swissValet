

Select <- function(){
  
  selkey <- getOption("selkey", default=list(file=c("fn","file","filename"),
                                             dir=c("path","dir", "pathname"),
                                             col=c("color", "col"),
                                             pch=c("pch"), locate=c("loc","xy"), 
                                             bookmark=c("wbm", "bmt")))
  
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel != "") {
    if(sel %in% selkey$pch) {
      
      pch <- pchPicker()
      if(!is.null(pch))
        txt <- gettextf('pch=%s, col="%s", bg="%s"', pch[["pch"]], pch[["col"]], pch[["bg"]])
      rstudioapi::insertText(txt)
      
    } else if(sel %in% selkey$col){
      txt <- eval(parse(text="ColPicker(newwin=TRUE)"))
      dev.off()
      rstudioapi::insertText(gettextf("col=c(%s)", paste(shQuote(txt), collapse=", ")))
      
    } else if(sel %in% selkey$file) {
      
      txt <- fileOpenDlg( fmt = "%path%%fname%.%ext%" )
      
      if( is.character(txt) && length(txt) == 1L && nzchar(txt) ) {
        rstudioapi::insertText( sprintf("%s=%s", sel, shQuote(txt)) )
      }
      
    } else if(sel %in% selkey$dir) {
      txt <- eval(parse(text="dir.choose()"))
      if(txt != "")
        rstudioapi::insertText(gettextf("%s=%s", sel, shQuote(txt)))
      
    } else if(sel %in% selkey$locate) {
      xy <- eval(parse(text="locator()"))
      if(!is.null(xy)){
        txt <- gettextf("%s <- list(\n  x = c(%s),\n  y = c(%s),\n  xlab = '$x', ylab = '$y')", 
                        sel, paste(xy$x, collapse=", "), paste(xy$y, collapse=", "))
        
        .insertSelectedText(txt)
      }
      
    } else if(sel %in% selkey$bookmark) {
      eval(parse(text="SelectDlgBookmark()"))
      
    } else {
      if(sel != ""){
        txt <- eval(parse(text=gettextf("selectVarDlg(%s)", sel)))
        if(txt != "") rstudioapi::insertText(txt)
      }
    }
  } else {
    cat("No selection!\n")
  }
  
  invisible()
  
}


# == internal helper functions =================================================


.insertSelectedText <- function(txt){
  
  rng <- rstudioapi::getActiveDocumentContext()
  
  # store selection
  sel <- rng$selection[[1]]$range
  
  # insert the text
  rstudioapi::modifyRange(txt)
  
  # select inserted text
  nsel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$range
  sel$end <- nsel$start
  rstudioapi::setSelectionRanges(sel)
  
}




fileOpenDlg <- function(
    fmt = c("auto", "path", "table", "load")
) {
  
  fn <- rstudioapi::selectFile()
  
  if (
    is.null(fn) ||
    !nzchar(fn)
  ) {
    return(invisible(NULL))
  }
  
  fn <- normalizePath(
    fn,
    winslash = "/",
    mustWork = FALSE
  )
  
  path <- paste0(
    dirname(fn),
    "/"
  )
  
  fname <- tools::file_path_sans_ext(
    basename(fn)
  )
  
  ext <- tolower(
    tools::file_ext(fn)
  )
  
  # -------------------------------------------------------------------
  # template expansion
  # -------------------------------------------------------------------
  
  if (
    length(fmt) == 1L &&
    grepl("%path%|%fname%|%ext%", fmt)
  ) {
    
    txt <- fmt
    
    txt <- gsub(
      "%path%",
      path,
      txt,
      fixed = TRUE
    )
    
    txt <- gsub(
      "%fname%",
      fname,
      txt,
      fixed = TRUE
    )
    
    txt <- gsub(
      "%ext%",
      ext,
      txt,
      fixed = TRUE
    )
    
    return(txt)
  }
  
  # -------------------------------------------------------------------
  # automatic mode detection
  # -------------------------------------------------------------------
  
  if (
    missing(fmt) ||
    is.null(fmt) ||
    identical(fmt, "auto")
  ) {
    
    fmt <- switch(
      ext,
      rda = "load",
      rdata = "load",
      csv = "table",
      dat = "table",
      "path"
    )
  }
  
  fmt <- match.arg(
    fmt,
    c("path", "table", "load")
  )
  
  # -------------------------------------------------------------------
  # code generation
  # -------------------------------------------------------------------
  
  switch(
    
    fmt,
    
    path = sprintf(
      '"%s"',
      fn
    ),
    
    table = sprintf(
      paste0(
        'd.%s <- read.table(',
        'file = "%s", ',
        'header = TRUE, ',
        'sep = ";", ',
        'na.strings = c("NA", "NULL"), ',
        'strip.white = TRUE',
        ')'
      ),
      fname,
      fn
    ),
    
    load = sprintf(
      'load(file = "%s")',
      fn
    )
  )
}
