


# == internal helper functions for tcltk dialogs ===============================

#' @keywords internal
.initDlg <- function(width, height, x=NULL, y=NULL, resizex=FALSE, 
                     resizey=FALSE, main="Dialog", ico="R"){
  
  top <- tcltk::tktoplevel()

  if(is.null(x)) x <- round((as.integer(tcltk::tkwinfo("screenwidth", top)) - width)/2)
  if(is.null(y)) y <- round((as.integer(tcltk::tkwinfo("screenheight", top)) - height)/2)
  
  geom <- gettextf("%sx%s+%s+%s", width, height, x, y)
  tcltk::tkwm.geometry(top, geom)
  tcltk::tkwm.title(top, main)
  tcltk::tkwm.resizable(top, resizex, resizey)
  # alternative:
  #    system.file("extdata", paste(ico, "ico", sep="."), package="DescTools")
  tcltk::tkwm.iconbitmap(top, .getImg(paste(ico, "ico", sep=".")))
  
  return(top)
  
}


#' @keywords internal
.getImg <- function(file){
  
  # looks for files either in /extdata  or in /inst/extdata
  path <- find.package(.thisPackage())
  
  res <- file.path(path, "extdata", file)
  if(file.exists(res))
    return(res)
  
  res <- file.path(path, "inst","extdata", file)
  if(file.exists(res))
    return(res)
  
  warning(gettextf("File %s not found in package folders."))
  
}



#' @keywords internal
.bringToFront <- function(main){
  
  info_sys <- Sys.info() # sniff the O.S.
  
  if (info_sys['sysname'] == 'Windows') { # MS Windows trick
    shell(gettextf("powershell -command [void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') ; [Microsoft.VisualBasic.Interaction]::AppActivate('%s') ", main))
  }
  
}


# http://infohost.nmt.edu/tcc/help/pubs/tkinter/web/ttk-Label.html
# good documentation
# http://infohost.nmt.edu/tcc/help/pubs/tkinter/web/index.html

# Tooltip for a widget inside a dialog, without a tcltk2 dependency.
# The tip is placed *inside* parent (a toplevel), so it cannot be hidden behind
# a topmost dialog window; the price is that it is clipped at the window border.
# text: a character string, or a function returning the text at hover time
#       (so the current content of a tclVar is always shown).
.TkTip <- function(widget, text, parent, delay = 400, wraplength = 400,
                   debug = FALSE) {
  
  tip <- NULL   # the tip label
  aid <- NULL   # id of the pending after event
  
  hide <- function() {
    if(!is.null(aid)) { tcltk::tcl("after", "cancel", aid); aid <<- NULL }
    if(!is.null(tip)) { tcltk::tkdestroy(tip); tip <<- NULL }
  }
  
  .int <- function(...) as.integer(tcltk::tclvalue(tcltk::tkwinfo(...)))
  
  show <- function() {
    
    aid <<- NULL
    txt <- if(is.function(text)) text() else text
    if(length(txt) != 1L || is.na(txt) || !nzchar(strTrim(txt)))
      return(invisible())
    
    hide()
    
    # created but not yet placed, hence not mapped and not visible
    tip <<- tcltk::tklabel(parent, text = txt, justify = "left",
                           background = "#FFFFE1", foreground = "#333333",
                           relief = "solid", borderwidth = 1,
                           wraplength = wraplength, padx = 4, pady = 2)
    
    # pointer position relative to the dialog, kept inside its borders
    px <- .int("pointerx", widget) - .int("rootx", parent)
    py <- .int("pointery", widget) - .int("rooty", parent)
    w <- .int("reqwidth", tip)
    h <- .int("reqheight", tip)
    
    x <- max(2, min(px + 12, .int("width", parent) - w - 2))
    y <- py + 20
    if(y + h > .int("height", parent) - 2) y <- py - h - 6   # above the pointer
    y <- max(2, min(y, .int("height", parent) - h - 2))
    
    tcltk::tkplace(tip, x = x, y = y)
    tcltk::tkraise(tip)
    
    if(debug)
      cat(gettextf("tip: x=%s y=%s w=%s h=%s text=%s\n", x, y, w, h, txt))
  }
  
  # register the callback once, so it cannot be collected before the delay is up
  showCmd <- tcltk::.Tcl.callback(show, environment())
  
  tcltk::tkbind(widget, "<Enter>", function() {
    if(debug) cat("tip: <Enter>\n")
    hide()
    aid <<- tcltk::tclvalue(tcltk::tcl("after", delay, showCmd))
  })
  tcltk::tkbind(widget, "<Leave>", hide)
  tcltk::tkbind(widget, "<ButtonPress>", hide)
  tcltk::tkbind(widget, "<Destroy>", hide)
  
  invisible(widget)
}

