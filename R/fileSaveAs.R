

fileSaveAs <- function() {
  
  sel <- rstudioapi::getActiveDocumentContext()$
    selection[[1]]$text
  
  if (!nzchar(sel)) {
    cli::cli_alert_warning("No text selected.")
    return(invisible(NULL))
  }
  
  # ---- tk parent -----------------------------------------------------------
  
  tt <- tcltk::tktoplevel()
  
  on.exit(
    try(tcltk::tkdestroy(tt), silent = TRUE)
  )
  
  w <- 1000
  h <- 700
  
  sw <- as.integer(
    tcltk::tkwinfo("screenwidth", tt)
  )
  
  sh <- as.integer(
    tcltk::tkwinfo("screenheight", tt)
  )
  
  x <- as.integer((sw - w) / 2)
  y <- as.integer((sh - h) / 2)
  
  tcltk::tkwm.geometry(
    tt,
    sprintf("%dx%d+%d+%d", w, h, x, y)
  )
  
  tcltk::tkwm.withdraw(tt)
  tcltk::tcl(
    "wm", "attributes",
    tt,
    topmost = TRUE
  )
  
  tcltk::tcl("raise", tt)
  tcltk::tkfocus(tt)
  
  
  # ---- dialog --------------------------------------------------------------
  
  f <- tcltk::tclvalue(
    tcltk::tkgetSaveFile(
      parent = tt,
      initialfile = sel,
      title = "Save a file...",
      filetypes = paste(
        "{{R Binary} {.rda}}",
        "{{CSV} {.csv}}",
        "{{Text} {.txt}}",
        "{{Excel} {.xlsx}}"
      ),
      defaultextension = ".rda"
    )
  )
  
  if (!nzchar(f))
    return(invisible(NULL))
  
  ext <- tolower(tools::file_ext(f))
  
  cmd <- switch(
    ext,
    
    rda = sprintf(
      "save(%s, file = %s)",
      sel,
      shQuote(f)
    ),
    
    csv = sprintf(
      "write.csv(%s, file = %s)",
      sel,
      shQuote(f)
    ),
    
    xlsx = sprintf(
      "writexl::write_xlsx(%s, path = %s)",
      sel,
      shQuote(f)
    ),
    
    txt = sprintf(
      paste0(
        "if (inherits(%s, 'character')) ",
        "writeLines(%s, con = %s) ",
        "else dput(%s, file = %s)"
      ),
      sel,
      sel,
      shQuote(f),
      sel,
      shQuote(f)
    ),
    
    NULL
  )
  
  if (is.null(cmd)) {
    cli::cli_alert_danger(
      "Unsupported file extension: {.file {ext}}"
    )
    return(invisible(NULL))
  }
  
  rstudioapi::sendToConsole(
    cmd,
    focus = FALSE
  )
  
  invisible(f)
}


