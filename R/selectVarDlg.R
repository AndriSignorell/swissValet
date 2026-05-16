
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
  xsel <- .selectListDlg( x, multiple = TRUE )

  if(useIndex == TRUE) {
    xsel <- which(x %in% xsel)
  } else {
    xsel <- shQuote(xsel)
  }
  
  if(!identical(xsel, "\"\""))
    txt <- paste("c(", paste(xsel, collapse=","),")", sep="")
  else
    txt <- ""
  
  .toClipboard(txt)
  
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
  .toClipboard(txt)
  
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
  
  .toClipboard(txt)
  
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
  
  .toClipboard(txt)
  
  invisible(txt)
}



#' @rdname selectVarDlg
#' @export
selectVarDlg.data.frame <- function(x, ...) {
  
  sel <- selectVarDlg.default( x = colnames(x), ...)
  if (length(sel) == 0) {
    return()
  }
  
  if(sel!="" && sel!="c()"){
    txt <- paste(deparse(substitute(x)), "[,",
                 sel, "]", sep="", collapse="")
    
    .toClipboard(txt)
    
  } else {
    txt <- ""
  }
  
  invisible(txt)
}



# == internal helper functions ============================================



#' Write text to clipboard
#'
#' Cross-platform clipboard helper using the \pkg{clipr} package.
#'
#' The function fails silently in non-interactive sessions or when
#' clipboard access is unavailable.
#'
#' @param x Object to write to the clipboard. Will be collapsed with
#'   `sep`.
#' @param sep Character string used to collapse `x`.
#' @param warn Logical. Should clipboard failures generate a warning?
#'
#' @return
#' Invisibly returns `TRUE` on success and `FALSE` otherwise.
#'
#' @keywords internal
#'
.toClipboard <- function(
    x,
    sep = "\n",
    warn = FALSE
) {
  
  # -------------------------------------------------------------------
  # interactive session only
  # -------------------------------------------------------------------
  
  if (!interactive())
    return(invisible(FALSE))
  
  # -------------------------------------------------------------------
  # clipr available?
  # -------------------------------------------------------------------
  
  if (!requireNamespace("clipr", quietly = TRUE)) {
    
    if (warn) {
      warning(
        "Package 'clipr' is required for clipboard support.",
        call. = FALSE
      )
    }
    
    return(invisible(FALSE))
  }
  
  # -------------------------------------------------------------------
  # normalize input
  # -------------------------------------------------------------------
  
  txt <- paste(
    as.character(x),
    collapse = sep
  )
  
  # -------------------------------------------------------------------
  # clipboard write
  # -------------------------------------------------------------------
  
  ok <- tryCatch(
    {
      clipr::write_clip(txt)
      TRUE
    },
    error = function(e) {
      
      if (warn) {
        warning(
          sprintf(
            "Clipboard write failed: %s",
            conditionMessage(e)
          ),
          call. = FALSE
        )
      }
      
      FALSE
    }
  )
  
  invisible(ok)
}




#' Tcl/Tk selection dialog
#'
#' Lightweight replacement for `utils::select.list()`
#' with improved spacing and keyboard handling.
#'
#' @param x Character vector of selectable items.
#' @param title Window title.
#' @param multiple Logical. Allow multiple selection?
#'
#' @return
#' Character vector of selected items.
#' Returns `character(0)` if cancelled.
#'
#' @keywords internal
#'
.selectListDlg <- function(
    x,
    title = "Select one or more",
    multiple = TRUE
) {
  
  requireNamespace("tcltk")
  
  x <- as.character(x)
  
  res <- character()
  
  # -------------------------------------------------------------------
  # geometry
  # -------------------------------------------------------------------
  
  nshow <- min(length(x), 18L)
  
  width <- 320L
  height <- 140L + nshow * 20L
  
  # -------------------------------------------------------------------
  # window
  # -------------------------------------------------------------------
  
  root <- tcltk::tktoplevel()
  
  tcltk::tkwm.title(
    root,
    title
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
  
  # center on screen
  sw <- as.integer(
    tcltk::tkwinfo("screenwidth", root)
  )
  
  sh <- as.integer(
    tcltk::tkwinfo("screenheight", root)
  )
  
  xpos <- as.integer((sw - width) / 2)
  ypos <- as.integer((sh - height) / 2)
  
  tcltk::tkwm.geometry(
    root,
    sprintf(
      "%dx%d+%d+%d",
      width,
      height,
      xpos,
      ypos
    )
  )
  
  tcltk::tcl(
    "wm", "attributes",
    root,
    topmost = TRUE
  )
  
  tcltk::tcl("raise", root)

    # NEU: Minimize/Maximize entfernen
  tcltk::tcl("wm", "attributes", root, "-toolwindow", TRUE)

  
  # -------------------------------------------------------------------
  # callbacks
  # -------------------------------------------------------------------
  
  OnOK <- function() {
    
    idx <- as.integer(
      tcltk::tkcurselection(lb)
    )
    
    if (length(idx)) {
      res <<- x[idx + 1L]
    }
    
    tcltk::tcl(
      "after",
      "idle",
      function() {
        tcltk::tkdestroy(root)
      }
    )
  }
  
  OnCancel <- function() {
    
    res <<- character()
    
    tcltk::tcl(
      "after",
      "idle",
      function() {
        tcltk::tkdestroy(root)
      }
    )
  }

  
  # -------------------------------------------------------------------
  # widgets
  # -------------------------------------------------------------------
  
  frm <- tcltk::tkframe(
    root,
    padx = 14,
    pady = 14
  )
  
  scr <- tcltk::tkscrollbar(frm)
  
  lb <- tcltk::tklistbox(
    frm,
    selectmode = if (multiple)
      "extended"
    else
      "single",
    yscrollcommand = function(...) {
      tcltk::tkset(scr, ...)
    },
    exportselection = FALSE,
    activestyle = "none",
    highlightthickness = 0,
    width = 28,
    height = nshow,
    background = "white",
    relief = "sunken",
    bd = 1
  )
  
  tcltk::tkconfigure(
    scr,
    command = function(...) {
      tcltk::tkyview(lb, ...)
    }
  )
  
  for (z in x) {
    
    tcltk::tkinsert(
      lb,
      "end",
      z
    )
  }
  
  frmBtn <- tcltk::tkframe(
    frm,
    pady = 10
  )
  
  butOK <- tcltk::tkbutton(
    frmBtn,
    text = "OK",
    width = 10,
    command = OnOK
  )
  
  butCancel <- tcltk::tkbutton(
    frmBtn,
    text = "Cancel",
    width = 10,
    command = OnCancel
  )
  
  # -------------------------------------------------------------------
  # layout
  # -------------------------------------------------------------------
  
  tcltk::tkgrid(
    frm,
    sticky = "news"
  )
  
  # listbox
  tcltk::tkgrid(
    lb,
    scr,
    row = 0,
    column = 0,
    sticky = "news"
  )
  
  tcltk::tkgrid.configure(
    scr,
    sticky = "ns"
  )
  
  # buttons
  tcltk::tkgrid(
    frmBtn,
    row = 1,
    column = 0,
    columnspan = 2,
    pady = c(12, 0),
    sticky = "ws"
  )
  
  tcltk::tkgrid(
    butOK,
    butCancel,
    padx = 6
  )
  
  # resizing behaviour
  tcltk::tkgrid.rowconfigure(frm, 0, weight = 1)
  tcltk::tkgrid.rowconfigure(frm, 1, weight = 0)
  tcltk::tkgrid.columnconfigure(frm, 0, weight = 1)
  tcltk::tkgrid.columnconfigure(frm, 1, weight = 0)
  
  # root mitwachsen lassen
  tcltk::tkgrid.rowconfigure(root, 0, weight = 1)
  tcltk::tkgrid.columnconfigure(root, 0, weight = 1)
  tcltk::tkgrid.configure(frm, sticky = "news")
  
  # -------------------------------------------------------------------
  # focus
  # -------------------------------------------------------------------
  
  tcltk::tkfocus(lb)
  
  tcltk::tcl(
    "focus",
    "-force",
    lb
  )
  
  # -------------------------------------------------------------------
  # key bindings
  # -------------------------------------------------------------------
  
  widgets <- list(
    root,
    lb,
    butOK,
    butCancel
  )
  
  for (w in widgets) {
    
    # ESC = cancel
    tcltk::tkbind(
      w,
      "<Escape>",
      function() {
        
        tcltk::tcl(
          "after",
          "idle",
          function() {
            OnCancel()
          }
        )
        
        "break"
      }
    )
    
    # ENTER = OK
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
  
  # double click = OK
  tcltk::tkbind(
    lb,
    "<Double-1>",
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
  
  # -------------------------------------------------------------------
  # finalize geometry
  # -------------------------------------------------------------------
  
  # let Tk calculate final widget sizes
  tcltk::tcl(
    "update",
    "idletasks"
  )
  
  # requested size
  reqw <- as.integer(
    tcltk::tkwinfo(
      "reqwidth",
      root
    )
  )
  
  reqh <- as.integer(
    tcltk::tkwinfo(
      "reqheight",
      root
    )
  )
  
  # screen size
  sw <- as.integer(
    tcltk::tkwinfo(
      "screenwidth",
      root
    )
  )
  
  sh <- as.integer(
    tcltk::tkwinfo(
      "screenheight",
      root
    )
  )
  
  # centered position
  xpos <- as.integer(
    (sw - reqw) / 2
  )
  
  ypos <- as.integer(
    (sh - reqh) / 2
  )
  
  # apply geometry AFTER layout exists
  tcltk::tkwm.geometry(
    root,
    sprintf(
      "%dx%d+%d+%d",
      reqw,
      reqh,
      xpos,
      ypos
    )
  )
  
  # prevent shrinking below correct size
  tcltk::tkwm.minsize(
    root,
    reqw,
    reqh
  )
  
  # -------------------------------------------------------------------
  # event loop
  # -------------------------------------------------------------------
  
  tcltk::tkwait.window(root)  
  
  res
  
}


