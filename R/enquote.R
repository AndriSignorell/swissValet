

enquote <- function() {
  
  if (!requireNamespace("tcltk", quietly = TRUE)) {
    stop("tcltk not available")
  }
  
  ctx <- rstudioapi::getActiveDocumentContext()
  sel <- ctx$selection[[1]]$text
  
  if (!nzchar(sel)) {
    cli_alert_info("No text selected.")
    return(invisible(NULL))
  }
  
  tt <- tcltk::tktoplevel()
  tcltk::tkwm.iconbitmap(tt, .getImg("R.ico"))
  
  # Fenster nach vorne
  tcltk::tkraise(tt)
  
  # Normaler Fokus-Versuch
  tcltk::tkfocus(tt)
  
  # Kurzer Delay + Fokus erzwingen (wichtig!)
  tcltk::tcl("after", 50, function() {
    tcltk::tcl("focus", "-force", tt)
  })
  
  tcltk::tkwm.title(tt, "Enquote")
  
  ## --- Position near mouse cursor ---------------------------------
  x <- as.integer(tcltk::tclvalue(tcltk::tcl("winfo", "pointerx", ".")))
  y <- as.integer(tcltk::tclvalue(tcltk::tcl("winfo", "pointery", ".")))
  tcltk::tkwm.geometry(tt, paste0("+", x + 10, "+", y + 10))
  
  ## --- Variables ---------------------------------------------------
  quote_type       <- tcltk::tclVar("double")
  custom_quote     <- tcltk::tclVar("")
  replace_newlines <- tcltk::tclVar(1)
  newline_repl     <- tcltk::tclVar(",")
  
  ## --- Quote block -------------------------------------------------
  qf <- tcltk::tkframe(tt, borderwidth = 2, relief = "groove")
  tcltk::tkpack(qf, fill = "x", padx = 10, pady = 6)
  
  tcltk::tklabel(qf, text = "Quote character") |>
    tcltk::tkpack(anchor = "w", padx = 5, pady = c(4, 6))
  
  qline <- tcltk::tkframe(qf)
  tcltk::tkpack(qline, anchor = "w", padx = 10)
  
  other_entry <- tcltk::tkentry(qline, textvariable = custom_quote, width = 10)
  
  set_focus_by_quote <- function() {
    qt <- tcltk::tclvalue(quote_type)
    if (identical(qt, "custom")) {
      tcltk::tkfocus(other_entry)
    } else {
      tcltk::tkfocus(ok_btn)
    }
  }
  
  tcltk::tkradiobutton(
    qline, text = "Single", value = "single",
    variable = quote_type, command = set_focus_by_quote
  ) |> tcltk::tkpack(side = "left", padx = 5)
  
  tcltk::tkradiobutton(
    qline, text = "Double", value = "double",
    variable = quote_type, command = set_focus_by_quote
  ) |> tcltk::tkpack(side = "left", padx = 5)
  
  tcltk::tkradiobutton(
    qline, text = "Other:", value = "custom",
    variable = quote_type, command = set_focus_by_quote
  ) |> tcltk::tkpack(side = "left", padx = 5)
  
  tcltk::tkpack(other_entry, side = "left", padx = c(2, 0), pady = c(2, 6))
  
  tcltk::tkbind(other_entry, "<FocusIn>", function() {
    tcltk::tclvalue(quote_type) <- "custom"
    tcltk::tcl("update", "idletasks")
  })
  
  ## --- Line break block --------------------------------------------
  nf <- tcltk::tkframe(tt, borderwidth = 2, relief = "groove")
  tcltk::tkpack(nf, fill = "x", padx = 10, pady = 6)
  
  tcltk::tklabel(nf, text = "Line breaks") |>
    tcltk::tkpack(anchor = "w", padx = 5, pady = c(4, 6))
  
  nline <- tcltk::tkframe(nf)
  tcltk::tkpack(nline, anchor = "w", padx = 10)
  
  newline_entry <- tcltk::tkentry(nline, textvariable = newline_repl, width = 10)
  
  tcltk::tkcheckbutton(
    nline,
    text = "Replace line breaks by:",
    variable = replace_newlines,
    command = function() {
      if (!as.logical(as.integer(tcltk::tclvalue(replace_newlines)))) {
        tcltk::tkfocus(ok_btn)
      }
    }
  ) |> tcltk::tkpack(side = "left", padx = 5)
  
  tcltk::tkpack(newline_entry, side = "left", padx = 5, pady = c(2, 6))
  
  tcltk::tkbind(newline_entry, "<FocusIn>", function() {
    tcltk::tclvalue(replace_newlines) <- 1
    tcltk::tcl("update", "idletasks")
  })
  
  ## --- Buttons -----------------------------------------------------
  bf <- tcltk::tkframe(tt)
  tcltk::tkpack(bf, pady = 10)
  
  btn_width <- 10
  
  ok_btn <- tcltk::tkbutton(
    bf,
    text = "OK",
    width = btn_width,
    command = function() {
      qt <- tcltk::tclvalue(quote_type)
      quote <- switch(
        qt,
        single = "'",
        double = "\"",
        custom = tcltk::tclvalue(custom_quote)
      )
      
      txt <- sel
      if (as.logical(as.integer(tcltk::tclvalue(replace_newlines)))) {
        txt <- gsub("\\R+", tcltk::tclvalue(newline_repl), txt, perl = TRUE)
      }
      
      # txt <- paste(shQuote(strsplit(txt, split="\n")[[1]]), collapse=",")
      # txt <- paste(sQuote (strsplit(txt, split="\n")[[1]]), collapse=",")
      
      parts <- trimws(unlist(strsplit(txt, ",")))
      res <- paste0(quote, parts, quote, collapse = ", ")
      
      rstudioapi::insertText(res)
      tcltk::tkdestroy(tt)
    }
  )
  
  tcltk::tkbind(tt, "<Return>", function() {
    tcltk::tkinvoke(ok_btn)
  })
  
  cancel_btn <- tcltk::tkbutton(
    bf,
    text = "Cancel",
    width = btn_width,
    command = function() tcltk::tkdestroy(tt)
  )
  
  tcltk::tkpack(ok_btn,     side = "left", padx = 6)
  tcltk::tkpack(cancel_btn, side = "left", padx = 6)
  
  ## --- Escape = Cancel ---------------------------------------------
  tcltk::tkbind(tt, "<Escape>", function() {
    tcltk::tkdestroy(tt)
  })
  
  tcltk::tkfocus(ok_btn)
  
  invisible()
  
}


