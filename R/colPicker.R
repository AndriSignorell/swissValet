

colPicker <- function(ord = "hsv",
                      label = "text",
                      mdim = c(38, 12)) {
  
  requireNamespace("tcltk")
  
  # ---- Farben vorbereiten ----
  cols <- colors()
  cols <- cols[-grep("^gr[ea]y", cols)]
  
  if (ord == "hsv") {
    rgbc <- col2rgb(cols)
    hsvc <- rgb2hsv(rgbc[1, ], rgbc[2, ], rgbc[3, ])
    cols <- cols[order(hsvc[1, ], hsvc[2, ], hsvc[3, ])]
  }
  
  zeilen <- mdim[1]
  spalten <- mdim[2]
  
  # auffüllen
  if (zeilen * spalten > length(cols)) {
    cols <- c(cols, rep(NA, zeilen * spalten - length(cols)))
  }
  
  # ---- Koordinaten ----
  x <- rep(1:spalten, each = zeilen)
  y <- rep(-1:-zeilen, times = spalten)
  
  # ---- exakte Plot-Grenzen ----
  xlim <- c(0.8, spalten + 0.8)
  ylim <- c(-zeilen - 0.7, -0.3)
  
  # xlim <- c(1, spalten + 0.5)
  # ylim <- c(-zeilen-0.5, -0.5)
  
  # ---- PNG erzeugen ----
  width  <- 1400
  height <- 900

  tf <- tempfile(fileext = ".png")
  
  png(tf, width = width, height = height)
  
  par(mar = c(0, 0, 0, 0))
  # par(oma = c(1, 1, 1, 1))
  
  plot(x, y,
       pch = 22,
       cex = 2.2,
       col = NA,
       bg = cols,
       bty = "n",
       xlim = xlim,
       ylim = ylim,
       xaxs = "i", yaxs = "i",
       xaxt = "n", yaxt = "n", ann = FALSE)
  
  if (label == "text") {
    text(x + 0.1, y, cols, adj = 0, cex = 0.8)
  }
  
  dev.off()

  
  # ---- GUI ----
  tt <- tktoplevel()
  tkwm.title(tt, "Color Picker")
  
  img <- tkimage.create("photo", file = tf)
  
  canvas <- tkcanvas(tt, width = width, height = height)
  tkpack(canvas)
  
  tkcreate(canvas, "image", 0, 0, anchor = "nw", image = img)
  
  result <- NULL
  
  # ---- Klick Mapping ----
  tkbind(canvas, "<Button-1>", function(W, x, y) {
    
    xclick <- as.numeric(x)
    yclick <- as.numeric(y)
    
    cat(gettextf("x: %s/%s", xclick, width), " ",
        gettextf("y: %s/%s", yclick, height))
    
    
    if (is.na(xclick) || is.na(yclick)) return()
    
    # Pixel → Plot-Koordinaten
    # xlim geht von 0.5 bis spalten+0.5  → Breite = spalten
    # ylim geht von -zeilen-0.5 bis -0.5 → Höhe   = zeilen
    # PNG-Pixel (0,0) ist oben links, y-Achse im Plot ist invertiert
    
    col_click <- floor((xclick / width)  * (spalten - 0.5)) + 1
    row_click <- floor((yclick / height) * zeilen) + 1
    
    # clamp
    col_click <- max(1, min(spalten, col_click))
    row_click <- max(1, min(zeilen,  row_click))
    
    idx <- (col_click - 1) * zeilen + row_click
    
    # cat("click:", col_click, row_click, "->", idx, 
    #     if (!is.na(cols[idx])) cols[idx] else "NA", "\n")

    if (idx >= 1 && idx <= length(cols) && !is.na(cols[idx])) {
      result <<- cols[idx]
      attr(result, "index") <<- idx
      tkdestroy(tt)
    }
    
  })
  
  # ---- Cancel ----
  cancel_fun <- function() {
    result <<- NULL
    tkdestroy(tt)
  }
  
  bottom <- tkframe(tt)
  tkpack(bottom, fill = "x")
  
  cancel_btn <- tkbutton(bottom, text = "Cancel", width = 10,
                         command = cancel_fun)
  tkpack(cancel_btn, side = "right", padx = 5, pady = 5)
  
  tkbind(tt, "<Escape>", function() cancel_fun())
  
  # ---- Modal Verhalten ----
  tkfocus(tt)
  tkgrab.set(tt)
  
  tkwait.window(tt)
  
  return(result)
  
}
