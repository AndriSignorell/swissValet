





sortLines <- function(){
  
  order <- .orderSelectionDlg()
  
  if(
    is.character(order) &&
    length(order) == 1L &&
    nzchar(order)
  ) {
    .orderLines(order)
  }
  
}



.orderLines <- function(order = c("asc", "desc", "rand")) {

  
  rng <- rstudioapi::getActiveDocumentContext()
  txt <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  
  if(txt != "") {
    
    rep_txt <- switch(match.arg(order, c("asc", "desc", "rand")),
                      
                      asc  = paste(sort(strsplit(txt, split="\n")[[1]]), collapse="\n"),
                      desc = paste(sort(strsplit(txt, split="\n")[[1]], decreasing = TRUE), collapse="\n"),
                      rand = paste(sample(strsplit(txt, split="\n")[[1]]), collapse="\n")
    )                
    
    if(length(grep("\\n$", txt))!=0)
      rep_txt <- paste0(rep_txt, "\n")
    
    rstudioapi::modifyRange(rep_txt)
    rstudioapi::setSelectionRanges(rng$selection[[1]]$range)
    
  } else {
    cat("No selection!\n")
  }
  
  
}


#' Select ordering mode
#'
#' Small Tcl/Tk dialog to choose how selected code elements
#' should be ordered.
#'
#' @return
#' Returns one of:
#'
#' - `"asc"`
#' - `"desc"`
#' - `"rand"`
#'
#' Returns `NULL` if cancelled.
#'

.orderSelectionDlg <- function() {
  
  requireNamespace("tcltk")
  
  res <- NULL
  
  # -------------------------------------------------------------------
  # window
  # -------------------------------------------------------------------
  
  root <- tcltk::tktoplevel()
  
  tcltk::tkwm.title(
    root,
    "Order Selection"
  )
  
  # center window roughly on screen
  w <- 270
  h <- 195
  
  sw <- as.integer(
    tcltk::tkwinfo("screenwidth", root)
  )
  
  sh <- as.integer(
    tcltk::tkwinfo("screenheight", root)
  )
  
  x <- as.integer((sw - w) / 2)
  y <- as.integer((sh - h) / 2)
  
  tcltk::tkwm.geometry(
    root,
    sprintf("%dx%d+%d+%d", w, h, x, y)
  )
  
  
  # icon
  ico <- system.file(
    "extdata",
    "R.ico",
    package = "swissValet"
  )
  
  if (file.exists(ico)) {
    
    try(
      tcltk::tcl(
        "wm",
        "iconbitmap",
        root,
        ico
      ),
      silent = TRUE
    )
  }
  
  tcltk::tcl(
    "wm", "attributes",
    root,
    topmost = TRUE
  )
  
  tcltk::tcl("raise", root)
  
  # -------------------------------------------------------------------
  # variables
  # -------------------------------------------------------------------
  
  # default = ascending
  rbval <- tcltk::tclVar("asc")
  
  # -------------------------------------------------------------------
  # callbacks
  # -------------------------------------------------------------------
  
  OnOK <- function() {
    
    res <<- tcltk::tclvalue(rbval)
    
    tcltk::tkdestroy(root)
  }
  
  OnCancel <- function() {
    
    res <<- NULL
    
    tcltk::tkdestroy(root)
  }
  
  # -------------------------------------------------------------------
  # widgets
  # -------------------------------------------------------------------
  
  frm <- tcltk::tkframe(
    root,
    padx = 15,
    pady = 15
  )
  
  # framed radiobutton area
  frmRadio <- tcltk::tkwidget(
    frm,
    "labelframe",
    text = "Ordering",
    padx = 10,
    pady = 10
  )
  
  rbAsc <- tcltk::tkradiobutton(
    frmRadio,
    text = "Ascending",
    value = "asc",
    variable = rbval,
    underline = 0
  )
  
  rbDesc <- tcltk::tkradiobutton(
    frmRadio,
    text = "Descending",
    value = "desc",
    variable = rbval,
    underline = 0
  )
  
  rbRand <- tcltk::tkradiobutton(
    frmRadio,
    text = "Random",
    value = "rand",
    variable = rbval,
    underline = 0
  )
  
  frmBtn <- tcltk::tkframe(frm)
  
  butOK <- tcltk::tkbutton(
    frmBtn,
    text = "OK",
    width = 8,
    command = OnOK
  )
  
  butCancel <- tcltk::tkbutton(
    frmBtn,
    text = "Cancel",
    width = 8,
    command = OnCancel
  )
  
  # -------------------------------------------------------------------
  # layout
  # -------------------------------------------------------------------
  
  tcltk::tkgrid(
    frm,
    sticky = "news"
  )
  
  tcltk::tkgrid(
    frmRadio,
    sticky = "news"
  )
  
  tcltk::tkgrid(
    rbAsc,
    sticky = "w",
    pady = 2
  )
  
  tcltk::tkgrid(
    rbDesc,
    sticky = "w",
    pady = 2
  )
  
  tcltk::tkgrid(
    rbRand,
    sticky = "w",
    pady = 2
  )
  
  tcltk::tkgrid(
    frmBtn,
    pady = c(12, 0)
  )
  
  tcltk::tkgrid(
    butOK,
    butCancel,
    padx = 5
  )
  
  # -------------------------------------------------------------------
  # focus
  # -------------------------------------------------------------------
  
  tcltk::tkfocus(rbAsc)
  
  tcltk::tcl(
    "focus",
    "-force",
    rbAsc
  )
  
  # -------------------------------------------------------------------
  # key bindings
  # -------------------------------------------------------------------
  
  widgets <- list(
    root,
    rbAsc,
    rbDesc,
    rbRand,
    butOK,
    butCancel
  )
  
  # ESC = cancel
  for (w in widgets) {
    
    tcltk::tkbind(
      w,
      "<Escape>",
      function() {
        OnCancel()
        "break"
      }
    )
    
    tcltk::tkbind(
      w,
      "<Return>",
      function() {
        
        tcltk::tcl(
          "after",
          "idle",
          function() {
            OnOK()
          }
        )
        
        "break"
      }
    )
  }
  
  # Alt+A
  tcltk::tkbind(
    root,
    "<Alt-a>",
    function() {
      tcltk::tclvalue(rbval) <- "asc"
      "break"
    }
  )
  
  # Alt+D
  tcltk::tkbind(
    root,
    "<Alt-d>",
    function() {
      tcltk::tclvalue(rbval) <- "desc"
      "break"
    }
  )
  
  # Alt+R
  tcltk::tkbind(
    root,
    "<Alt-r>",
    function() {
      tcltk::tclvalue(rbval) <- "rand"
      "break"
    }
  )
  
  # -------------------------------------------------------------------
  # event loop
  # -------------------------------------------------------------------
  
  tcltk::tkwait.window(root)
  
  invisible(res)
}


