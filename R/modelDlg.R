


buildModel <- function(){
  
  sel <- rstudioapi::getActiveDocumentContext()$selection[[1]]$text
  if(sel==""){
    lst <- .globalDataFrames()
    if(!is.null(lst)){
      sel <- selectVarDlg(x = lst)[1]
      if(!is.null(sel)){
        sel <- eval(parse(text=sel))[1]
      }
    }
  }
  
  if(sel != ""){
    txt <- eval(parse(text=gettextf(".modelDlg(%s)", sel)))
    rstudioapi::insertText(txt)
  } else {
    cat("No selection!\n")
  }
 
  invisible()
  
}



# http://infohost.nmt.edu/tcc/help/pubs/tkinter/web/ttk-Label.html
# good documentation
# http://infohost.nmt.edu/tcc/help/pubs/tkinter/web/index.html

.modelDlg <- function(x, ...){
  
  requireNamespace("tcltk")
  
  .GetModTxt <- function()
    tcltk::tclvalue(tcltk::tkget(tfModx, "0.0", "end"))
  
  .EmptyListBox <- function(){
    n <- as.character(tcltk::tksize(tlist.var))
    for (i in (n:0)) tcltk::tkdelete(tlist.var, i)
  }
  
  .PopulateListBox <- function(x){
    for (z in x) {
      tcltk::tkinsert(tlist.var, "end", paste0(" ", z))
    }
  }
  
  .AddVar <- function(sep, pack = NULL, connect="+") {
    
    var.name <- as.numeric(tcltk::tkcurselection(tlist.var))
    lst <- .GetVarName(as.character(tcltk::tkget(tlist.var, 0, "end")))
    
    if (length(var.name) == 0)
      tcltk::tkmessageBox(message = "No variable selected",
                          icon = "info", type = "ok")
    
    if (length(var.name) > 0) {
      
      txt <- strTrim(.GetModTxt())
      if(is.null(pack))
        vn <- strTrim(lst[var.name + 1])
      else
        vn <- strTrim(gettextf(pack, lst[var.name + 1]))
      
      txt <- strTrim(paste(ifelse(txt=="", "", connect), paste(vn, collapse=sep), ""), method="left")
      if(connect == "-" & .GetModTxt() == "\n")
        txt <- paste(" . - ", txt)
      
      tcltk::tkinsert(tfModx, "insert", txt, "notwrapped")
    }
  }
  
  .BtnAddVar <- function() .AddVar(" + ")
  .BtnAddMult <- function() .AddVar(" * ")
  .BtnAddInt <- function() .AddVar(" : ")
  .BtnAddPoly <- function() .AddVar(sep=" + ", pack="poly(%s, 2)")
  .BtnAddMin <- function() .AddVar(" - ", connect="-")
  # .BtnAddPipe <- function() .AddVar(" | ")
  .BtnAddI <- function() .AddVar(sep=" + ", pack="I(%s)")
  
  
  
  imgAsc <-  tcltk::tclVar()
  tclimgAsc <-  tcltk::tkimage.create("photo", imgAsc, file = .getImg("SortListAsc.gif"))
  imgDesc <-  tcltk::tclVar()
  tclimgDesc <-  tcltk::tkimage.create("photo", imgDesc, file = .getImg("SortListDesc.gif"))
  imgNone <-  tcltk::tclVar()
  tclimgNone <-  tcltk::tkimage.create("photo", imgNone, file = .getImg("SortListNo.gif"))
  
  .BtnSortVarListAsc <- function() .SortVarList("a")
  .BtnSortVarListDesc <- function() .SortVarList("d")
  .BtnSortVarListNone <- function() .SortVarList("n")
  
  
  .InsertLHS <- function() {
    
    var.name <- as.numeric(tcltk::tkcurselection(tlist.var))
    lst <- .GetVarName(as.character(tcltk::tkget(tlist.var, 0, "end")))
    
    if (length(var.name) == 0)
      tcltk::tkmessageBox(message = "No variable selected",
                          icon = "info", type = "ok")
    
    if (length(var.name) > 0) {
      tcltk::tclvalue(tflhs) <- paste(lst[var.name + 1], collapse=", ")
    }
  }
  
  .SortVarList <- function(ord){
    
    lst <- as.character(tcltk::tkget(tlist.var, 0, "end"))
    
    # for (i in (length(names(x)):0)) tkdelete(tlist.var, i)
    .EmptyListBox()
    
    if(ord == "a"){
      v <- strTrim(sort(lst, decreasing = FALSE))
    } else if(ord == "d"){
      v <- strTrim(sort(lst, decreasing = TRUE))
    } else {
      v <- strTrim(.VarNames()[names(x) %in% .GetVarName(lst)])
    }
    
    .PopulateListBox(v)
    
  }
  
  .FilterVarList <- function(){
    
    pat <- strTrim(tcltk::tclvalue(tffilter))
    # print(pat)
    if(pat=="")
      v <- .VarNames()
    else
      v <- grep(pattern = pat, .VarNames(), value=TRUE, fixed=TRUE)
    
    for (i in (length(names(x)):0)) tcltk::tkdelete(tlist.var, i)
    
    .PopulateListBox(v)
    
    # tcltk::tclvalue(frmVar$text) <- gettextf("Variables (%s/%s):", length(v), length(names(x)))
    tcltk::tkconfigure(frmVar, text=gettextf("Variables (%s/%s):", length(v), length(names(x))))
  }
  
  .SelectVarList <- function(){
    
    var.name <- as.numeric(tcltk::tkcurselection(tlist.var))
    lst <- .GetVarName(as.character(tcltk::tkget(tlist.var, 0, "end")))
    
    if (length(var.name) > 0) {
      txt <- strTrunc(label(x[, strTrim(lst[var.name + 1])]), 30)
      if(length(txt) == 0) txt <- " "
      cltxt <- class(x[, strTrim(lst[var.name + 1])])
      if(any(cltxt %in% c("factor","ordered")))
        cltxt <- paste0(cltxt, "(", max(nlevels(x[, strTrim(lst[var.name + 1])])), ")")
      tcltk::tclvalue(tflbl) <- gettextf("%s\n  %s", paste(cltxt, collapse=", "), txt)
    } else {
      tcltk::tclvalue(tflbl) <- "\n"
    }
  }
  
  
  .VarNames <- function(){
    
    cabbr <- function(x){
      
      if(class(x)[1]=="integer") "i"
      else if(class(x)[1]=="numeric") "n"  
      else if(class(x)[1]=="factor") gettextf("f_%s", nlevels(x))  
      else if(class(x)[1]=="ordered") gettextf("o_%s", nlevels(x))  
      else if(class(x)[1]=="Date") "d"  
      else if(class(x)[1]=="character") "c"  
      else if(class(x)[1]=="logical") "l"  
      else class(x)[1]   
    }
    
    sapply(names(x), function(z) gettextf(" %s   - %s", z, cabbr(x[, z])))
    
  }
  
  .GetVarName <- function(x){
    strTrim(gsub("-.*", "", x))
  }
  
  
  fam <- "comic"
  size <- 10
  myfont <- tcltk::tkfont.create(family = fam, size = size)
  mySerfont <- tcltk::tkfont.create(family = "Times", size = size)
  
  tfmodtype <- tcltk::tclVar("")
  tfmodx <- tcltk::tclVar("")
  tflhs <- tcltk::tclVar("")
  tffilter <- tcltk::tclVar("")
  tflbl <- tcltk::tclVar("\n")
  tfframe <- tcltk::tclVar("Variables:")
  # gettextf("Variables (%s):", length(names(x)))
  mod_x <- NA_character_
  
  e1 <- environment()
  modx <- character()
  # old, repl. by 0.99.22: xname <- deparse(substitute(x))
  xname <- paste(strTrim(deparse(substitute(x))), collapse=" ")
  
  if (!missing(x)) {
    if(inherits(x, "formula")) {
      
      # would be nice to pick up a formula here, to be able to edit the formula
      # https://rviews.rstudio.com/2017/02/01/the-r-formula-method-the-good-parts/
      
      # try to extract the name of the data.frame from match.call
      xname <- strExtract(gsub("^.+data = ", "\\1", paste(deparse(match.call()), collapse=" ")), ".+[[:alnum:]]")
      
      tcltk::tclvalue(tflhs) <- deparse(x[[2]])
      mod_x <- deparse(x[[3]])
      
      x <- eval(parse(text=xname, parent.env()))
      
    } else if(!is.data.frame(x))
      stop("x must be a data.frame")
    
    
  } else {
    stop("Some data must be provided, example: ModelDlg(iris)")
  }
  
  
  OnOK <- function() {
    if(tcltk::tclvalue(tfmodtype)=="")
      modelx <- "%s"
    else
      modelx <- models[tcltk::tclvalue(tfmodtype)]
    
    assign("modx", gettextf(modelx, paste(
      strTrim(tcltk::tclvalue(tflhs)), " ~ ",
      strTrim(.GetModTxt()), ", data=", xname, sep="")), envir = e1)
    
    tcltk::tkdestroy(root)
  }
  
  # do not update screen
  tcltk::tclServiceMode(on = FALSE)
  
  # create window
  root <- .initDlg(width = 880, height = 532, resizex=TRUE, resizey=TRUE,
                   main=gettextf("Build Model Formula (%s)", xname), ico="R")
  
  # define widgets
  content <- tcltk::tkframe(root, padx=10, pady=10)
  
  
  # Variable list
  frmVar <- tcltk::tkwidget(content, "labelframe", text=gettextf("Variables (%s/%s):", length(names(x)), length(names(x))),
                            fg = "black", padx = 10, pady = 10, font = myfont)
  
  
  tfFilter <- tcltk::tkentry(frmVar, textvariable=tffilter, width= 20, bg="white")
  tfButSortAsc <- tcltk::tkbutton(frmVar, image = tclimgAsc, compound="none",
                                  command = .BtnSortVarListAsc, height = 21, width = 21)
  tfButSortDesc <- tcltk::tkbutton(frmVar, image = tclimgDesc, compound="none",
                                   command = .BtnSortVarListDesc, height = 21, width = 21)
  tfButSortNone <- tcltk::tkbutton(frmVar, image=tclimgNone, compound="none",
                                   command = .BtnSortVarListNone, height = 21, width = 21)
  var.scr <- tcltk::tkscrollbar(frmVar, repeatinterval = 5,
                                command = function(...) tcltk::tkyview(tlist.var, ...))
  
  tlist.var <- tcltk::tklistbox(frmVar, selectmode = "extended",
                                yscrollcommand = function(...)
                                  tcltk::tkset(var.scr, ...), background = "white",
                                exportselection = FALSE, activestyle= "none", highlightthickness=0,
                                height=20, width=20, font = myfont)
  tfVarLabel <- tcltk::tklabel(frmVar, justify="left", width=26, anchor="w", textvariable=tflbl, font=myfont)
  
  
  
  .PopulateListBox(.VarNames())
  
  
  tcltk::tkbind(tlist.var)
  tcltk::tkgrid(tfFilter, row=0, padx=0, sticky = "n")
  tcltk::tkgrid(tcltk::tklabel(frmVar, text="  "), row=0, column=1)
  tcltk::tkgrid(tfButSortAsc, row=0, column=2, padx=0, sticky = "n")
  tcltk::tkgrid(tfButSortDesc, row=0, column=3,  sticky = "n")
  tcltk::tkgrid(tfButSortNone, row=0, column=4, sticky = "n")
  tcltk::tkgrid(tcltk::tklabel(frmVar, text=" "))
  tcltk::tkgrid(tlist.var, var.scr, row=2, columnspan=5, sticky = "news")
  tcltk::tkgrid(tfVarLabel, row=3, columnspan=5, pady=3, sticky = "es")
  tcltk::tkgrid.configure(var.scr, sticky = "news")
  # tcltk2::tk2tip(tlist.var, "List of variables in data frame")
  
  # Buttons
  frmButtons <- tcltk::tkwidget(content, "labelframe", text = "",  bd=0,
                                fg = "black", padx = 5, pady = 25)
  
  tfButLHS <- tcltk::tkbutton(frmButtons, text = ">",
                              command = .InsertLHS, height = 1, width = 2, font=myfont)
  
  tfButAdd <- tcltk::tkbutton(frmButtons, text = "+",
                              command = .BtnAddVar, height = 1, width = 2, font=myfont)
  tfButMult <- tcltk::tkbutton(frmButtons, text = "*",
                               command = .BtnAddMult, height = 1, width = 2, font=myfont)
  tfButInt <- tcltk::tkbutton(frmButtons, text = ":",
                              command = .BtnAddInt,
                              height = 1, width = 2, font=myfont)
  tfButPoly <- tcltk::tkbutton(frmButtons, text = "x\U00B2",
                               command = .BtnAddPoly,
                               height = 1, width = 2, font=myfont)
  tfButMin <- tcltk::tkbutton(frmButtons, text = "-",
                              command = .BtnAddMin, height = 1, width = 2, font=myfont)
  #  tfButPipe <- tcltk::tkbutton(frmButtons, text = "|",
  #                              command = .BtnAddPipe, height = 1, width = 2, font=myfont)
  tfButI <- tcltk::tkbutton(frmButtons, text="I",
                            command = .BtnAddI, height = 1, width = 2, font=mySerfont)
  
  tcltk::tkgrid(tfButLHS, row = 0, rowspan=10, padx = 5, sticky = "s")
  tcltk::tkgrid(tcltk::tklabel(frmButtons, text="\n\n"))
  tcltk::tkgrid(tfButAdd, row = 40, padx = 5, sticky = "s")
  tcltk::tkgrid(tfButMin, row = 50, padx = 5, sticky = "s")
  tcltk::tkgrid(tfButMult, row = 60, padx = 5, sticky = "s")
  tcltk::tkgrid(tfButInt, row = 70, padx = 5, sticky = "s")
  # tcltk::tkgrid(tfButPipe, row = 80, padx = 5, sticky = "s")
  tcltk::tkgrid(tfButPoly, row = 80, padx = 5, sticky = "s")
  tcltk::tkgrid(tfButI, row = 90, padx = 5, sticky = "s")
  
  
  # Model textbox
  frmModel <- tcltk::tkwidget(content, "labelframe", text = "Model:",
                              fg = "black", padx = 10, pady = 10, font = myfont)
  
  # get the model list from the options
  models <- getOption("DTAmodels", default = options(DTAmodels = list(
    "linear regression (OLS)" = "r.lm <- lm(%s)"
    ,"logistic regression" = 'r.logit <- glm(%s, fitfn="binomial")'
  )))
  
  
  
  tfComboModel <- ttkcombobox(frmModel,
                              values = if(!is.null(models)) names(models) else "",
                              textvariable = tfmodtype,  # font = myfont, 
                              state = "normal",     # or "readonly"
                              justify = "left", width=30)
  
  tfLHS <- tcltk::tkentry(frmModel, textvariable=tflhs, bg="white",  width=45)
  tfModx <- tcltk::tktext(frmModel, bg="white", height=20, width=70, wrap="word", padx=7, pady=5, font=myfont)
  tcltk::tkgrid(tfLHS, column=0, row=0, pady=10, sticky="nws")
  tcltk::tkgrid(tfComboModel, column=0, row=0, pady=10, sticky="e")
  tcltk::tkgrid(tcltk::tklabel(frmModel, text="~"), row=1, sticky="w")
  tcltk::tkgrid(tfModx, column=0, row=2, pady=10, sticky="nws")
  if(!all(is.na(mod_x)))
    tcltk::tkinsert(tfModx, "insert", mod_x, "notwrapped")
  
  
  
  
  # root
  tfButOK = tcltk::tkbutton(content, text="OK", command=OnOK, width=6)
  tfButCanc = tcltk::tkbutton(content, text="Cancel", width=7,
                              command=function() tcltk::tkdestroy(root))
  
  tcltk::tkbind(tfFilter, "<KeyRelease>", .FilterVarList)
  tcltk::tkbind(tlist.var, "<ButtonRelease>", .SelectVarList)
  tcltk::tkbind(tlist.var, "<KeyRelease>", .SelectVarList)
  tcltk::tkbind(tlist.var, "<Double-1>", .InsertLHS)
  
  
  # build GUI
  tcltk::tkgrid(content, column=0, row=0, sticky = "nwes")
  tcltk::tkgrid(frmVar, padx = 5, pady = 5, row = 0, column = 0,
                rowspan = 20, columnspan = 1, sticky = "ns")
  
  tcltk::tkgrid(frmButtons, padx = 5, pady = 5, row = 0, column = 2,
                rowspan = 20, columnspan = 1, sticky = "ns")
  
  tcltk::tkgrid(frmModel, padx = 5, pady = 5, row = 0, column = 3,
                rowspan = 20,
                sticky = "nes")
  
  tcltk::tkgrid(tfButOK, column=3, row=30, ipadx=15, padx=5, sticky="es")
  tcltk::tkgrid(tfButCanc, column=0, row=30, ipadx=15, padx=5, sticky="ws")
  
  tcltk::tkfocus(tlist.var)
  tcltk::tclServiceMode(on = TRUE)
  
  tcltk::tcl("wm", "attributes", root, topmost=TRUE)
  
  
  ## --- bring window to front ----------------------------------------
  
  tcltk::tcl("raise", root)
  
  tcltk::tcl(
    "wm", "attributes",
    root,
    topmost = TRUE
  )
  
  ## --- focus ---------------------------------------------------------
  
  tcltk::tkfocus(tfModx)
  
  tcltk::tcl(
    "focus",
    "-force",
    tfModx
  )
  
  ## --- Escape = Cancel ----------------------------------------------
  
  for (w in list(
    root,
    tfModx,
    tfFilter,
    tlist.var,
    tfLHS
  )) {
    
    tcltk::tkbind(
      w,
      "<Escape>",
      function() {
        tcltk::tkdestroy(root)
        "break"
      }
    )
  }
  
  # Hilfsfunktion: OnOK nur aufrufen wenn root noch existiert
  .SafeOnOK <- function() {
    if (as.logical(tcltk::tkwinfo("exists", root))) {
      OnOK()
    }
  }
  
  # <Control-Return> in tfModx
  tcltk::tkbind(
    tfModx,
    "<Control-Return>",
    function() {
      tcltk::tcl("after", "idle", .SafeOnOK)
      "break"
    }
  )
  
  # <Return> für alle anderen Widgets
  for (w in list(tfFilter, tlist.var, tfLHS)) {
    tcltk::tkbind(
      w,
      "<Return>",
      function() {
        .SafeOnOK()
        "break"
      }
    )
  }
  
  ## --- event loop ---------------------------------------------------
  
  tcltk::tkwait.window(root)
  
  if(is.character(modx) && length(modx) == 1L && nzchar(modx))
    return(modx)
  else
    invisible()
  
}



# == internal helper functions ================================================

.globalDataFrames <- function() {
  
  objs <- eapply(
    .GlobalEnv,
    is.data.frame
  )
  
  names(objs)[unlist(objs)]
}


