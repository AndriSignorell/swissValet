
# insert_in <- function() {
#   rstudioapi::insertText(" %in% ", location = )
# }


# nice dialog: rstudioapi::selectFile()




Str1 <- function(){
  
  requireNamespace("DescToolsX")
  
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel != "") {
    rstudioapi::sendToConsole(gettextf("DescToolsX::strX(%s, max.level=1)", sel), focus = FALSE)
  } else {
    cat("No selection!\n")
  }
}

Example <- function(){
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel != "") {
    rstudioapi::sendToConsole(gettextf("example(%s)", sel), focus = FALSE)
  } else {
    cat("No selection!\n")
  }
}



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
      txt <- eval(parse(text="FileOpenDlg(fmt='%path%%fname%.%ext%')"))
      if(txt != "")
        rstudioapi::insertText(gettextf("%s=%s", sel, shQuote(txt)))

    } else if(sel %in% selkey$dir) {
      txt <- eval(parse(text="dir.choose()"))
      if(txt != "")
        rstudioapi::insertText(gettextf("%s=%s", sel, shQuote(txt)))

    } else if(sel %in% selkey$locate) {
      xy <- eval(parse(text="locator()"))
      if(!is.null(xy)){
        txt <- gettextf("%s <- list(\n  x = c(%s),\n  y = c(%s),\n  xlab = '$x', ylab = '$y')", 
                        sel, paste(xy$x, collapse=", "), paste(xy$y, collapse=", "))

        .InsertSelectedText(txt)
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



.InsertSelectedText <- function(txt){
  
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



Plot <- function(){
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel != "") {
    if(sel=="mar")
      rstudioapi::sendToConsole("PlotMar()", focus = FALSE)
    else
      rstudioapi::sendToConsole(gettextf("plot(%s)", sel), focus = FALSE)
  } else {
    cat("No selection!\n")
  }
}


PlotD <- function(){

  requireNamespace("DescToolsX")

  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel != "") {
    rstudioapi::sendToConsole(gettextf("plot(DescToolsX::desc(%s))", sel), focus = FALSE)
  } else {
    cat("No selection!\n")
  }
}





Info <- function(){

  .Info <- function(x){

    class_x <- strwrap(paste(class(x), collapse=", "),
                       width= getOption("width") - nchar("  Class(es):   "))
    class_x[-1] <- paste(strrep(" ", nchar("  Class(es):  ")), class_x[-1])

    cat(gettextf("Properties -------- \n  Object:      %s\n  TypeOf:      %s\n  Class(es):   %s\n  Mode:        %s\n  Dimension:   %s\n  Length:      %s\n  Size:        %s\n  Attributes:  ",
                 deparse(substitute(x)), typeof(x),
                 paste(class_x, collapse="\n"),
                 mode(x),
                 ifelse(is.null(dim(x)), "NULL", toString(dim(x))), length(x),
                 paste0(fm(as.numeric(object.size(x)), fmt="engabb",  digits=1), "B")
                 ))
    if(!is.null(attributes(x))) {
      cat("\n")
      opt <- options(width=getOption("width") - 4)
      cat(paste("    ", capture.output(attributes(x))), sep="\n")
      options(opt)
    } else
      cat("none\n\n")
  }

  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text

  if(sel != ""){
#    rstudioapi::sendToConsole(gettextf(".Info(%s)", sel), execute = TRUE, focus = FALSE)
    eval(parse(text = gettextf(".Info(%s)", sel)))

  } else {
    cat("No selection!\n")
  }

}



FileOpen <- function(){

  txt <- eval(parse(text="FileOpenDlg(fmt=NULL)"))
  if(txt != "") {
    rstudioapi::insertText(txt)
  }
}


FileBrowserOpen <- function(){
  
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel != ""){
    
    path <- eval(parse(text=sel)) # should we do some cleansing here?
    
    si <- Sys.info()["sysname"]
    
    if (si == "Darwin") {
      # mac
      system2("open", path)
      
    } else if (si == "Windows") {
      # win
      shell.exec(path)
      
    } else if (si == "Linux") {
      # linux
      system(paste0("xdg-open ", path))
      
    } else {
      stop("Open browser is not implemented for your system (",
           si, ") in this package (due to incompetence of the author).")
    }

  } else {
    cat("No selection!\n")
  }
  
}



FileImport <- function(){

  txt <- eval(parse(text="FileImportDlg()"))
  if(txt != "") {
    rstudioapi::insertText(txt)
  }
}




IntView <- function(){
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel != "") {
    rstudioapi::sendToConsole(gettextf("View(%s)", sel), focus = FALSE)
  } else {
    cat("No selection!\n")
  }
}












SortAsc <- function(){
  
  rng <- rstudioapi::getActiveDocumentContext()
  txt <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text

  if(txt != "") {
    rep_txt <- paste(sort(strsplit(txt, split="\n")[[1]]), collapse="\n")
    if(length(grep("\\n$", txt))!=0)
      rep_txt <- paste0(rep_txt, "\n")
    
    rstudioapi::modifyRange(rep_txt)
    rstudioapi::setSelectionRanges(rng$selection[[1]]$range)
    
  } else {
    cat("No selection!\n")
  }
  
  
}


SortDesc <- function(){
  rng <- rstudioapi::getActiveDocumentContext()
  txt <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  
  if(txt != "") {
    rep_txt <- paste(sort(strsplit(txt, split="\n")[[1]], decreasing = TRUE), collapse="\n")
    if(length(grep("\\n$", txt))!=0)
      rep_txt <- paste0(rep_txt, "\n")
    rstudioapi::modifyRange(rep_txt)
    rstudioapi::setSelectionRanges(rng$selection[[1]]$range)
    
  } else {
    cat("No selection!\n")
  }
  
  
}


Shuffle <- function(){
  
  rng <- rstudioapi::getActiveDocumentContext()
  txt <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  
  if(txt != "") {
    rep_txt <- paste(sample(strsplit(txt, split="\n")[[1]]), collapse="\n")
    if(length(grep("\\n$", txt))!=0)
      rep_txt <- paste0(rep_txt, "\n")
    
    rstudioapi::modifyRange(rep_txt)
    rstudioapi::setSelectionRanges(rng$selection[[1]]$range)
    
  } else {
    cat("No selection!\n")
  }
  
  
}







NewObject <- function(){

  obj <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(obj == "") obj <- "m"

  m <- edit(data.frame())

  switch(obj,
     "m" = {
        m <- as.matrix(m)

        if(!all(dimnames(m)[[2]] == paste("var", 1:length(dimnames(m)[[2]]), sep="")))
          dnames <- gettextf(", \n       dimnames=list(%s)", toString(dimnames(m)))
        else
          dnames <- ""

        if(!is.numeric(m))
          m[!is.na(m)] <- shQuote(m[!is.na(m)])

        txt <- gettextf("m <- matrix(c(%s), nrow=%s%s)\n",
                        toString(m), dim(m)[1], dnames)
      },
     "c"={
       m <- as.vector(m)
       txt <- gettextf("v <- %s\n", toString(m))

     },
     "d"={
       txt <- paste("d <- data.frame(", paste(names(m), "=", m, collapse = ", "), ")\n", sep="")
       # genuine data.frame
     }
  )

  rstudioapi::insertText(txt)

}



InspectPnt <- function(){

  requireNamespace("DescToolsX")

  .ToClipboard <- function (x, ...) {

    sn <- Sys.info()["sysname"]
    if (sn == "Darwin") {
      file <- pipe("pbcopy")
      cat(x, file = file, ...)
      close(file)
    }
    else if (sn == "Windows") {
      cat(x, file = "clipboard", ...)
    }
    else {
      stop("Writing to the clipboard is not implemented for your system (",
           sn, ") in this package.")
    }
  }


  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text

  if(sel != ""){
    i <- eval(parse(text=gettextf("DescToolsX::IdentifyA(%s, poly=TRUE)", sel)))

    .ToClipboard(paste("c(", paste(i, collapse=","), ")", sep=""))

    # Todo:
    # Display directly by looking up the data in the formula
    # View(mtcars[i,])

  } else {
    cat("No selection!\n")
  }



}





SavePlot <- function(){
  
  requireNamespace("DescToolsX")
  
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  
  if(sel != "") {
    
    # look for something like 'SavePlot' in the stringpart before the first :
    ok <- grepl("SavePlot", strsplit(sel, ":")[[1]][1], ignore.case = TRUE)
    
    if(ok) {
      
      opendevcmd <- strTrim(regmatches(sel, gregexpr("(?s)(?<=:).*?(?=\\{)", sel, perl=TRUE)))
      # remove comments
      opendevcmd <- paste(gsub("^#", "", strsplit(opendevcmd, split="\n")[[1]]), collapse=" ")
      # open device according to the given code 
      eval(parse(text = opendevcmd))
      
      # extract R code between brackets {}
      code <- regmatches(sel, gregexpr("(?s)(?<=\\{).*(?=\\})", sel, perl=TRUE))[[1]]
      # run code
      eval(parse(text = code))
      
      # close the device
      dev.off()
      
    }

    
  } else {
    cat("No selection!\n")
  }
  
}




