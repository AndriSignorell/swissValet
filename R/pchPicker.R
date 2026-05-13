




#' @keywords internal
pchPicker <- function() {
  
  requireNamespace("tcltk")
  
  pchs <- 0:25
  selected <- rep(FALSE, length(pchs))
  
  col_val <- tclVar("black")
  bg_val  <- tclVar("lightblue")
  
  size <- 70
  ncol <- 6
  
  result <- NULL
  
  # ---- Mini-Plot ----
  make_icon <- function(pch, selected = FALSE, col = "black", bg = "lightblue") {
    tf <- tempfile(fileext = ".png")
    
    png(tf, width = size, height = size, bg = "white")
    par(mar = c(0,0,0,0))
    plot.new()
    
    draw_col <- if (selected) "red" else col
    
    if (pch %in% 21:25) {
      points(0.5, 0.6, pch = pch, cex = 2.5,
             col = draw_col, bg = bg)
    } else {
      points(0.5, 0.6, pch = pch, cex = 2.5,
             col = draw_col)
    }
    
    text(0.5, 0.15, labels = pch, cex = 0.8)
    
    dev.off()
    
    tkimage.create("photo", file = tf)
  }
  
  # ---- GUI ----
  tt <- tktoplevel()
  tkwm.title(tt, "Pick Point Character (pch)")
  tcltk::tkwm.iconbitmap(tt, .getImg("R.ico"))
  
  ## --- Position near mouse cursor ---------------------------------
  x <- as.integer(tcltk::tclvalue(tcltk::tcl("winfo", "pointerx", ".")))
  y <- as.integer(tcltk::tclvalue(tcltk::tcl("winfo", "pointery", ".")))
  tcltk::tkwm.geometry(tt, paste0("+", x + 10, "+", y + 10))
  
  
  tkgrab.set(tt)
  tkfocus(tt)
  
  main <- tkframe(tt)
  tkpack(main, fill = "both", expand = TRUE, padx = 10, pady = 10)
  
  # --- Controls (Grid für sauberes Alignment) ---
  ctrl <- tkframe(main)
  tkpack(ctrl, anchor = "w", pady = 5)
  
  # Row 1: col
  tkgrid(tklabel(ctrl, text = "Color (col):"), row = 0, column = 0, sticky = "w")
  
  col_entry <- tkentry(ctrl, textvariable = col_val, width = 12)
  tkgrid(col_entry, row = 0, column = 1, padx = 5)
  
  col_btn <- tkbutton(ctrl, text = "...", width = 3,
                      command = function() {
                        new_col <- colPicker()
                        if (!is.null(new_col))
                          tclvalue(col_val) <- new_col
                        draw_all()
                      })
  tkgrid(col_btn, row = 0, column = 2)
  
  # Row 2: bg
  tkgrid(tklabel(ctrl, text = "Background (bg):"), row = 1, column = 0, sticky = "w")
  
  bg_entry <- tkentry(ctrl, textvariable = bg_val, width = 12)
  tkgrid(bg_entry, row = 1, column = 1, padx = 5)
  
  bg_btn <- tkbutton(ctrl, text = "...", width = 3,
                     command = function() {
                       new_col <- colPicker()
                       if (!is.null(new_col))
                         tclvalue(bg_val) <- new_col
                       draw_all()
                     })
  tkgrid(bg_btn, row = 1, column = 2)
  
  # gleiche Höhe für Entry + Button erzwingen (Tk Trick)
  tkconfigure(col_btn, height = 1)
  tkconfigure(bg_btn, height = 1)
  
  # --- Canvas ---
  canvas <- tkcanvas(main,
                     width = ncol * size,
                     height = ceiling(length(pchs)/ncol) * size,
                     bg = "white")
  tkpack(canvas, pady = 10)
  
  images <- vector("list", length(pchs))
  
  draw_all <- function() {
    tkdelete(canvas, "all")
    
    col_now <- tclvalue(col_val)
    bg_now  <- tclvalue(bg_val)
    
    for (i in seq_along(pchs)) {
      row <- (i-1) %/% ncol
      col <- (i-1) %% ncol
      
      x <- col * size + size/2
      y <- row * size + size/2
      
      img <- make_icon(pchs[i], selected[i], col_now, bg_now)
      images[[i]] <<- img
      
      tkcreate(canvas, "image", x, y, image = img)
      
      if (selected[i]) {
        tkcreate(canvas, "rectangle",
                 x - size/2 + 5, y - size/2 + 5,
                 x + size/2 - 5, y + size/2 - 5,
                 outline = "red", width = 3)
      }
    }
  }
  
  draw_all()
  
  # ---- Klick ----
  tkbind(canvas, "<Button-1>", function(W, x, y) {
    x <- as.numeric(x)
    y <- as.numeric(y)
    
    if (is.na(x) || is.na(y)) return()
    
    col_click <- floor(x / size)
    row_click <- floor(y / size)
    
    idx <- row_click * ncol + col_click + 1
    
    if (!is.na(idx) && idx >= 1 && idx <= length(pchs)) {
      selected[idx] <<- !selected[idx]
      draw_all()
    }
  })
  tkbind(canvas, "<Double-Button-1>", function(...) ok_fun())
  
  # ---- Live Update ----
  tkbind(col_entry, "<KeyRelease>", function(...) draw_all())
  tkbind(bg_entry, "<KeyRelease>", function(...) draw_all())
  
  # ---- Buttons unten rechts ----
  bottom <- tkframe(main)
  tkpack(bottom, fill = "x")
  
  spacer <- tkframe(bottom)
  tkpack(spacer, side = "left", expand = TRUE)
  
  ok_fun <- function() {
    result <<- list(
      pch = pchs[selected],
      col = tclvalue(col_val),
      bg  = tclvalue(bg_val)
    )
    tkdestroy(tt)
  }
  
  cancel_fun <- function() {
    result <<- NULL
    tkdestroy(tt)
  }
  
  ok_btn <- tkbutton(bottom, text = "OK", width = 10, command = ok_fun)
  cancel_btn <- tkbutton(bottom, text = "Cancel", width = 10, command = cancel_fun)
  
  tkpack(cancel_btn, side = "right", padx = 5, pady = 5)
  tkpack(ok_btn, side = "right", padx = 5, pady = 5)
  
  # ---- Key Bindings ----
  tkbind(tt, "<Return>", function() ok_fun())
  tkbind(tt, "<Escape>", function() cancel_fun())
  
  tkwait.window(tt)
  
  return(result)
}


