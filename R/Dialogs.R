

# ToDo 2021-02-04:
# BookmarkDlg   update of deleted list entrys 
#               rename bookmark




## GUI-Elements: select variables by dialog, FileOpen, DescDlg, ObjectBrowse ====


.LsDataFrame <- function(){
  # list all data.frames in the GlobalEnvironment
  lst <- unlist(eapply(.GlobalEnv, is.data.frame))
  if(!is.null(lst))
    res <- names(which(lst))
  else
    res <- NULL
  
  return(res)
  
}






.ToClipboard <- function (x, ...) {

  # This fails on Linux with
  #
  # * checking examples ... ERROR
  # Running examples in 'DescTools-Ex.R' failed The error most likely occurred in:
  #
  #   > base::assign(".ptime", proc.time(), pos = "CheckExEnv") ### Name:
  # > ToClipboard ### Title: Write Text to Clipboard ### Aliases:
  # > ToClipboard

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






FileOpenDlg <- function(fmt=NULL) {

  fn <- rstudioapi::selectFile() # file.choose()
  # fn <- tcltk::tclvalue(tcltk::tkgetOpenFile())

  op <- options(useFancyQuotes = FALSE)
  # switch from backslash to slash
  fn <- gsub("\\\\", "/", fn)

  path <- paste0(dirname(fn), "/")
  fname <- tools::file_path_sans_ext(basename(fn))
  ext <- tools::file_ext(fn)

  if(is.null(fmt)) {
    if(ext %in% c("rda", "RData"))
      fmt <- 3
    else if(ext %in% c("dat", "csv"))
      fmt <- 2
    else
      fmt <- 1
  }


  # read.table text:
  if(fmt == 1) {
    fmt <- "\"%path%%fname%.%ext%\""

  } else if( fmt == 2) {
    fmt="d.%fname% <- read.table(file = \"%path%%fname%.%ext%\", header = TRUE, sep = \";\", na.strings = c(\"NA\",\"NULL\"), strip.white = TRUE)"

  } else if( fmt == 3) {
    fmt="load(file = \"%path%%fname%.%ext%\")"

  }


  rcmd <- gsub("%fname%", fname, gsub("%ext%", ext, gsub( "%path%", path, fmt)))

  # utils::writeClipboard(rcmd)
  # .ToClipboard(rcmd)

  options(op)

  return(rcmd)

}







ColorDlg <- function() {
  requireNamespace("tcltk", quietly = FALSE)
  return(as.character(tcltk::tcl("tk_chooseColor", title="Choose a color")))
}


dir.choose <- function(default = "", caption = "Select directory"){
  requireNamespace("tcltk", quietly = FALSE)
  tcltk::tk_choose.dir(default = default, caption = caption)
}



.ImportSPSS <- function(datasetname = "dataset") {
  # read.spss
  # function (file, use.value.labels = TRUE, to.data.frame = FALSE,
  #           max.value.labels = Inf, trim.factor.names = FALSE, trim_values = TRUE,
  #           reencode = NA, use.missings = to.data.frame)
  e1 <- environment()
  env.dsname <- character()
  env.use.value.labels <- logical()
  env.to.data.frame <- logical()
  env.max.value.labels <- character()
  env.trim.factor.names <- logical()
  env.trim.values <- logical()
  env.reencode <- character()
  env.use.missings <- logical()
  lst <- NULL

  OnOK <- function() {
    assign("lst", list(), envir = e1)
    assign("env.dsname", tcltk::tclvalue(dsname), envir = e1)
    assign("env.use.value.labels", tcltk::tclvalue(use.value.labels), envir = e1)
    assign("env.to.data.frame", tcltk::tclvalue(to.data.frame), envir = e1)
    assign("env.max.value.labels", tcltk::tclvalue(max.value.labels), envir = e1)
    assign("env.trim.factor.names", tcltk::tclvalue(trim.factor.names), envir = e1)
    assign("env.trim.values", tcltk::tclvalue(trim.values), envir = e1)
    assign("env.reencode", tcltk::tclvalue(reencode), envir = e1)
    assign("env.use.missings", tcltk::tclvalue(use.missings), envir = e1)
    tcltk::tkdestroy(top)
  }

  top <- .initDlg(350, 300, main="Import SPSS Dataset")

  dsname <- tcltk::tclVar(datasetname)
  dsnameFrame <- tcltk::tkframe(top, padx = 10, pady = 10)
  entryDsname <- tcltk::ttkentry(dsnameFrame, width=30, textvariable=dsname)

  optionsFrame <- tcltk::tkframe(top, padx = 10, pady = 10)

  use.value.labels <- tcltk::tclVar("1")
  use.value.labelsCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Use value labels", variable=use.value.labels)

  to.data.frame <- tcltk::tclVar("1")
  to.data.frameCheckBox <- tcltk::ttkcheckbutton(optionsFrame,
                                                 text="Convert value labels to factor levels", variable=to.data.frame)
  max.value.labels <- tcltk::tclVar("Inf")
  entryMaxValueLabels <- tcltk::ttkentry(optionsFrame, width=30, textvariable=max.value.labels)

  trim.values <- tcltk::tclVar("1")
  trim.valuesCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Ignore trailing spaces when matching"
                                               , variable=trim.values)
  trim.factor.names <- tcltk::tclVar("1")
  trim.factor.namesCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Trim trailing spaces from factor levels"
                                                     , variable=trim.factor.names)
  reencode <- tcltk::tclVar("")
  entryReencode <- tcltk::ttkentry(optionsFrame, width=30, textvariable=reencode)

  use.missings <- tcltk::tclVar("1")
  use.missingsCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Use missings",
                                                variable=use.missings)

  tcltk::tkgrid(tcltk::tklabel(dsnameFrame, text="Enter name for data set:  "), entryDsname, sticky="w")
  tcltk::tkgrid(dsnameFrame, columnspan=2, sticky="w")
  tcltk::tkgrid(use.value.labelsCheckBox, sticky="w")
  tcltk::tkgrid(to.data.frameCheckBox, sticky="nw")
  tcltk::tkgrid(tcltk::ttklabel(optionsFrame, text="Maximal value label:"), sticky="nw")
  tcltk::tkgrid(entryMaxValueLabels, padx=20, sticky="nw")
  tcltk::tkgrid(trim.valuesCheckBox, sticky="w")
  tcltk::tkgrid(trim.factor.namesCheckBox, sticky="w")
  tcltk::tkgrid(tcltk::ttklabel(optionsFrame, text="Reencode character strings to the current locale:"), sticky="nw")
  tcltk::tkgrid(entryReencode, padx=20, sticky="nw")
  tcltk::tkgrid(use.missingsCheckBox, sticky="w")
  tcltk::tkgrid(optionsFrame, sticky="w")

  buttonsFrame <- tcltk::tkframe(top, padx = 10, pady = 10)
  tfButOK <- tcltk::tkbutton(buttonsFrame, text = "OK", command = OnOK, width=10)
  tfButCanc <- tcltk::tkbutton(buttonsFrame, width=10, text = "Cancel", command = function() tcltk::tkdestroy(top))

  tcltk::tkgrid(tfButOK, tfButCanc)
  tcltk::tkgrid.configure(tfButCanc, padx=c(6,6))
  tcltk::tkgrid.columnconfigure(buttonsFrame, 0, weight=2)
  tcltk::tkgrid.columnconfigure(buttonsFrame, 1, weight=1)

  tcltk::tkgrid(buttonsFrame, sticky="ew")
  tcltk::tkwait.window(top)

  if(!is.null(lst)){
    lst <- list(dsname=env.dsname, use.value.labels=as.numeric(env.use.value.labels),
                to.data.frame=as.numeric(env.to.data.frame),
                max.value.labels=env.max.value.labels, trim.factor.names=as.numeric(env.trim.factor.names),
                trim.values=as.numeric(env.trim.values), reencode=env.reencode, use.missings=as.numeric(env.use.missings)  )
  }
  return(lst)

}


.ImportSYSTAT <- function(datasetname = "dataset") {

  e1 <- environment()
  env.dsname <- character()
  env.to.data.frame <- logical()
  lst <- NULL

  top <- .initDlg(350, 140, main="Import SYSTAT Dataset")

  OnOK <- function() {
    assign("lst", list(), envir = e1)
    assign("env.dsname", tcltk::tclvalue(dsname), envir = e1)
    assign("env.to.data.frame", tcltk::tclvalue(to.data.frame ), envir = e1)
    tcltk::tkdestroy(top)
  }

  dsname <- tcltk::tclVar(datasetname)
  dsnameFrame <- tcltk::tkframe(top, padx = 10, pady = 10)
  entryDsname <- tcltk::ttkentry(dsnameFrame, width=30, textvariable=dsname)

  optionsFrame <- tcltk::tkframe(top, padx = 10, pady = 10)
  to.data.frame <- tcltk::tclVar("1")
  to.data.frameCheckBox <- tcltk::ttkcheckbutton(optionsFrame,
                                                 text="Convert dataset to data.frame", variable=to.data.frame)

  tcltk::tkgrid(tcltk::tklabel(dsnameFrame, text="Enter name for data set:  "), entryDsname, sticky="w")
  tcltk::tkgrid(dsnameFrame, columnspan=2, sticky="w")
  tcltk::tkgrid(to.data.frameCheckBox, sticky="w")
  tcltk::tkgrid(optionsFrame, sticky="w")

  buttonsFrame <- tcltk::tkframe(top, padx = 10, pady = 10)
  tfButOK <- tcltk::tkbutton(buttonsFrame, text = "OK", command = OnOK, width=10)
  tfButCanc <- tcltk::tkbutton(buttonsFrame, width=10, text = "Cancel", command = function() tcltk::tkdestroy(top))

  tcltk::tkgrid(tfButOK, tfButCanc)
  tcltk::tkgrid.configure(tfButCanc, padx=c(6,6))
  tcltk::tkgrid.columnconfigure(buttonsFrame, 0, weight=2)
  tcltk::tkgrid.columnconfigure(buttonsFrame, 1, weight=1)

  tcltk::tkgrid(buttonsFrame, sticky="ew")
  tcltk::tkwait.window(top)

  if(!is.null(lst)){
    lst <- list(dsname=env.dsname, to.data.frame=as.numeric(env.to.data.frame))
  }
  return(lst)

}



.ImportStataDlg <- function(datasetname = "dataset") {

  #   function (file, convert.dates = TRUE, convert.factors = TRUE,
  #             missing.type = FALSE, convert.underscore = FALSE, warn.missing.labels = TRUE)

  e1 <- environment()
  env.dsname <- character()
  env.convert.dates <- logical()
  env.convert.factors <- logical()
  env.convert.underscore <- logical()
  env.missing.type <- logical()
  env.warn.missing.labels <- logical()
  lst <- NULL

  OnOK <- function() {
    assign("lst", list(), envir = e1)
    assign("env.dsname", tcltk::tclvalue(dsname), envir = e1)
    assign("env.convert.dates", tcltk::tclvalue(convert.dates), envir = e1)
    assign("env.convert.factors", tcltk::tclvalue(convert.factors), envir = e1)
    assign("env.convert.underscore", tcltk::tclvalue(convert.underscore), envir = e1)
    assign("env.missing.type", tcltk::tclvalue(missing.type), envir = e1)
    assign("env.warn.missing.labels", tcltk::tclvalue(warn.missing.labels), envir = e1)
    tcltk::tkdestroy(top)
  }

  top <- .initDlg(350, 220, main="Import Stata Dataset")

  dsname <- tcltk::tclVar(datasetname)
  dsnameFrame <- tcltk::tkframe(top, padx = 10, pady = 10)
  entryDsname <- tcltk::ttkentry(dsnameFrame, width=30, textvariable=dsname)

  optionsFrame <- tcltk::tkframe(top, padx = 10, pady = 10)

  convert.factors <- tcltk::tclVar("1")
  convert.factorsCheckBox <- tcltk::ttkcheckbutton(optionsFrame,
                                                   text="Convert value labels to factor levels", variable=convert.factors)
  convert.dates <- tcltk::tclVar("1")
  convert.datesCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Convert dates to R format", variable=convert.dates)

  missing.type <- tcltk::tclVar("1")
  missing.typeCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Multiple missing types (>=Stata 8)"
                                                , variable=missing.type)
  convert.underscore <- tcltk::tclVar("1")
  convert.underscoreCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Convert underscore to period"
                                                      , variable=convert.underscore)
  warn.missing.labels <- tcltk::tclVar("1")
  warn.missing.labelsCheckBox <- tcltk::ttkcheckbutton(optionsFrame, text="Warn on missing labels",
                                                       variable=warn.missing.labels)

  tcltk::tkgrid(tcltk::tklabel(dsnameFrame, text="Enter name for data set:  "), entryDsname, sticky="w")
  tcltk::tkgrid(dsnameFrame, columnspan=2, sticky="w")
  tcltk::tkgrid(convert.datesCheckBox, sticky="w")
  tcltk::tkgrid(convert.factorsCheckBox, sticky="nw")
  tcltk::tkgrid(missing.typeCheckBox, sticky="w")
  tcltk::tkgrid(convert.underscoreCheckBox, sticky="w")
  tcltk::tkgrid(warn.missing.labelsCheckBox, sticky="w")
  tcltk::tkgrid(optionsFrame, sticky="w")

  buttonsFrame <- tcltk::tkframe(top, padx = 10, pady = 10)
  tfButOK <- tcltk::tkbutton(buttonsFrame, text = "OK", command = OnOK, width=10)
  tfButCanc <- tcltk::tkbutton(buttonsFrame, width=10, text = "Cancel", command = function() tcltk::tkdestroy(top))

  tcltk::tkgrid(tfButOK, tfButCanc)
  tcltk::tkgrid.configure(tfButCanc, padx=c(6,6))
  tcltk::tkgrid.columnconfigure(buttonsFrame, 0, weight=2)
  tcltk::tkgrid.columnconfigure(buttonsFrame, 1, weight=1)

  tcltk::tkgrid(buttonsFrame, sticky="ew")
  tcltk::tkwait.window(top)

  if(!is.null(lst)){
    lst <- list(dsname=env.dsname, convert.factors=as.numeric(env.convert.factors),
                convert.dates=as.numeric(env.convert.dates), convert.underscore=as.numeric(env.convert.underscore),
                missing.type=as.numeric(env.missing.type), warn.missing.labels=as.numeric(env.warn.missing.labels)  )
  }
  return(lst)

}


FileImportDlg <- function(auto_type = TRUE, env = .GlobalEnv)  {

  requireNamespace("tcltk", quietly = FALSE)

  filename <- tcltk::tclvalue(tcltk::tkgetOpenFile(filetypes= "{{All files} *}
     {{SPSS Files} {.sav}} {{SAS xport files} {.xpt, .xport}}
     {{SYSTAT} {*.sys, *.syd}} {{MiniTab} {.mtp}}
     {{Stata Files} {.dta}}"))

  # nicht topmost, aber wie mach ich das dann??
  # tcl("wm", "attributes", root, topmost=TRUE)

  if (filename=="") return()

  path <- splitPath(filename)

  fformats <- c("SPSS","SAS","SYSTAT", "Minitab","Stata")

  if(auto_type){
    xsel <- switch(toupper(path$extension),
                   "SAV"="SPSS",
                   "DTA"="Stata",
                   "SYD"="SYSTAT",
                   "SYS"="SYSTAT",
                   "MTP"="MiniTab",
                   "XPT"="SAS",
                   "XPORT"="SAS",
                   "SAS"="SAS",
                   select.list(fformats, multiple = FALSE, graphics = TRUE))
  } else {
    xsel <- select.list(fformats, multiple = FALSE, graphics = TRUE)
  }

  switch(xsel,
         "MiniTab"={
           zz <- foreign::read.mtp(file=filename)
         },
         "SYSTAT"={
           dlg <- .ImportSYSTAT(paste("d.", path$filename, sep=""))
           if(is.null(dlg)) return()
           zz <- foreign::read.systat(file=filename, to.data.frame = dlg$to.data.frame)
         },
         "SPSS"={
           dlg <- .ImportSPSS(paste("d.", path$filename, sep=""))
           if(is.null(dlg)) return()
           zz <- foreign::read.spss(file=filename, use.value.labels = dlg$use.value.labels,
                                    to.data.frame = dlg$to.data.frame,
                                    max.value.labels = dlg$max.value.labels,
                                    trim.factor.names = dlg$trim.factor.names,
                                    trim_values = dlg$trim_value,
                                    reencode = ifelse(dlg$reencode=="", NA, dlg$reencode),
                                    use.missings = dlg$use.missings)
         },
         "SAS"={
           print("not yet implemented.")
         },
         "Stata"={
           dlg <- .ImportStataDlg(paste("d.", path$filename, sep=""))
           if(is.null(dlg)) return()
           zz <- foreign::read.dta(file=filename, convert.dates = dlg[["convert.dates"]], convert.factors = dlg[["convert.factors"]],
                                   missing.type = dlg[["missing.type"]], convert.underscore = dlg[["convert.underscore"]],
                                   warn.missing.labels = dlg[["warn.missing.labels"]])
         })
  assign(dlg[["dsname"]], zz, envir=env)
  message(gettextf("Dataset %s has been successfully created!\n\n", dlg[["dsname"]]))
  # Exec(gettextf("print(str(%s, envir = %s))", dlg[["dsname"]],  deparse(substitute(env))))
}





ColPicker <- function(locator=TRUE, ord=c("hsv","default"), label=c("text","hex","dec"),
                      mdim = c(38, 12), newwin = FALSE) {

  usr <- par(no.readonly=TRUE)
  opt <- options(locatorBell = FALSE)

  on.exit({
    par(usr)
    options(opt)
  })

  # this does not work and CRAN does not allow windows()
  # dev.new(width=13, height=7)
  if(newwin == TRUE)
    dev.new(width=13, height=7, noRStudioGD = TRUE)

  # plots all named colors:   PlotRCol(lbel="hex") hat noch zuviele Bezeichnungen
  if( !is.null(dev.list()) ){
    curwin <- dev.cur()
    on.exit({
      dev.set(curwin)
      par(usr)
    })
  }


  # colors without greys (and grays...) n = 453
  cols <- colors()[-grep( pattern="^gr[ea]y", colors())]

  # set order
  switch( match.arg( arg=ord, choices=c("hsv","default") )
          , "default" = { # do nothing
          }
          , "hsv" = {
            rgbc <- col2rgb(cols)
            hsvc <- rgb2hsv(rgbc[1,],rgbc[2,],rgbc[3,])
            cols <- cols[ order(hsvc[1,],hsvc[2,],hsvc[3,]) ]
          }
  )


  zeilen <- mdim[1]; spalten <- mdim[2] # 660 Farben
  farben.zahlen <- matrix( 1:spalten, nrow=zeilen, ncol=spalten, byrow=TRUE) # Matrix fuer Punkte

  if(zeilen*spalten > length(cols))
    cols <- c(cols, rep(NA, zeilen*spalten - length(cols)) ) # um 3 NULL-Werte erweitern

  x_offset <- 0.5
  x <- farben.zahlen[, 1:spalten]  # x-Werte (Zahlen)
  y <- -rep(1:zeilen, spalten)     # y-Werte (Zahlen)

  par(mar=c(0,0,0,0), mex=0.001, xaxt="n", yaxt="n", ann=F)
  plot( x, y
        , pch=22    # Punkttyp Rechteck
        , cex=2     # Vergroesserung Punkte
        , col=NA
        , bg=cols   # Hintergrundfarben
        , bty="n"   # keine Box
        , xlim=c(1, spalten+x_offset) # x-Wertebereich
  )
  switch( match.arg( arg=label, choices=c("text","hex","dec") )
          , "text" = {
            text( x+0.1, y, cols, adj=0, cex=0.6 ) # Text Farben
          }
          , "hex" = {     # HEX-Codes
            text( x+0.1, y, adj=0, cex=0.6,
                  c(apply(apply(col2rgb(cols[1:(length(cols)-3)]), 2, sprintf, fmt=" %02X"), 2, paste, collapse=""), rep("",3))
            )
          }
          , "dec" = {     # decimal RGB-Codes
            text( x+0.1, y, adj=0, cex=0.6,
                  c(apply(apply(col2rgb(cols[1:(length(cols)-3)]), 2, sprintf, fmt=" %03d"), 2, paste, collapse=""), rep("",3))
            )
          }
  )

  z <- locator()

  idx <- with(lapply(z, round), (x-1) * zeilen + abs(y))
  return(cols[idx])

}



PlotPar <- function(){
  # plots the most used plot parameters

  usr <- par(no.readonly=TRUE);  on.exit(par(usr))

  if( !is.null(dev.list()) ){
    curwin <- dev.cur()
    on.exit({
      dev.set(curwin)
      par(usr)
      })
  }

  # this does not work and CRAN does not allow windows()
  # dev.new(width=7.2, height=4)

  par( mar=c(0,0,0,0), mex=0.001, xaxt="n", yaxt="n", ann=F, xpd=TRUE)
  plot( x=1:25, y=rep(11,25), pch=1:25, cex=2, xlab="", ylab=""
      , frame.plot=FALSE, ylim=c(-1,15), col=2, bg=3)
  points( x=1:25, y=rep(12.5,25), pch=1:35, cex=2, col=1)
  text( x=1:25, y=rep(9.5,25), labels=1:25, cex=0.8 )
  segments( x0=1, x1=4, y0=0:5, lty=6:1, lwd=3 )
  text( x=5, y=6:0, adj=c(0,0.5), labels=c("0 = blank", "1 = solid (default)", "2 = dashed", "3 = dotted", "4 = dotdash", "5 = longdash", "6 = twodash") )
  segments( x0=10, x1=12, y0=0:6, lty=1, lwd=7:1 )
  text( x=13, y=0:6, adj=c(0,0.5), labels=7:1 )
  points( x=rep(15,7), y=0:6, cex=rev(c(0.8,1,1.5,2,3,4,7)) )
  text( x=16, y=0:6, adj=c(0,0.5), labels=rev(c(0.8,1,1.5,2,3,4,7)) )
  text( x=c(1,1,10,15,18,18), y=c(14,7.5,7.5,7.5,7.5,2.5), labels=c("pch","lty","lwd","pt.cex","adj","col"), cex=1.3, col="grey40")
  adj <- expand.grid(c(0,0.5,1),c(0,0.5,1))
  for( i in 1:nrow(adj)  ){
    text( x=18+adj[i,1]*7, y=3.5+adj[i,2]*3, label=paste("text", paste(adj[i,], collapse=",") ), adj=unlist(adj[i,]), cex=0.8 )
  }
  points( x=18:25, y=rep(1,8), col=1:8, pch=15, cex=2 )
  text( x=18:25, y=0, adj=c(0.5,0.5), labels=1:8, cex=0.8 )

}



PlotPch <- function (col = NULL, bg = NULL, newwin = FALSE) {

  if (newwin == TRUE)
    dev.new(width=2, height=5, noRStudioGD=TRUE)
    # dev.new(width=3, height=2, xpos=100, ypos=600, noRStudioGD = TRUE)

  usr <- par(no.readonly = TRUE)
  on.exit(par(usr))
  if (!is.null(dev.list())) {
    curwin <- dev.cur()
    on.exit({
      dev.set(curwin)
      par(usr)
    })
  }

  if(is.null(col))
    col <- pal("Helsana")[1]  # DescTools::hred
  if(is.null(bg))
    bg <- pal("Helsana")[4]   # hecru

  par(mar = c(0, 0, 0, 0), mex = 0.001, xaxt = "n", yaxt = "n",
      ann = F, xpd = TRUE)
  plot(y = 1:25, x = rep(3, 25), pch = 25:1, cex = 1.5, xlab = "",
       ylab = "", frame.plot = FALSE, xlim = c(-1, 15))
  points(y = 1:25, x = rep(6, 25), pch = 25:1, cex = 1.5,
         col = col, bg = bg)
  text(y = 25:1, x = rep(9, 25), labels = 1:25, cex = 0.8)

}




PlotMar <- function(){

  hred <- pal("Helsana")[1]
  hgreen <- pal("Helsana")[7]
  horange <- pal("Helsana")[2]
  hecru <- pal("Helsana")[4]

  par(oma=c(3,3,3,3))  # all sides have 3 lines of space
  #par(omi=c(1,1,1,1)) # alternative, uncomment this and comment the previous line to try

  # - The mar command represents the figure margins. The vector is in the same ordering of
  #   the oma commands.
  #
  # - The default size is c(5,4,4,2) + 0.1, (equivalent to c(5.1,4.1,4.1,2.1)).
  #
  # - The axes tick marks will go in the first line of the left and bottom with the axis
  #   label going in the second line.
  #
  # - The title will fit in the third line on the top of the graph.
  #
  # - All of the alternatives are:
  #	- mar: Specify the margins of the figure in number of lines
  #	- mai: Specify the margins of the figure in number of inches

  par(mar=c(5,4,4,2) + 0.1)
  #par(mai=c(2,1.5,1.5,.5)) # alternative, uncomment this and comment the previous line

  # Plot
  plot(x=1:10, y=1:10, type="n", xlab="X", ylab="Y")	# type="n" hides the points

  # Place text in the plot and color everything plot-related red
  text(5,5, "Plot", col=hred, cex=2)
  text(5,4, "text(5,5, \"Plot\", col=\"red\", cex=2)", col=hred, cex=1)
  box("plot", col=hred)

  # Place text in the margins and label the margins, all in green
  mtext("Figure", side=3, line=2, cex=2, col=hgreen)
  mtext("par(mar=c(5,4,4,2) + 0.1)", side=3, line=1, cex=1, col=hgreen)
  mtext("Line 0", side=3, line=0, adj=1.0, cex=1, col=hgreen)
  mtext("Line 1", side=3, line=1, adj=1.0, cex=1, col=hgreen)
  mtext("Line 2", side=3, line=2, adj=1.0, cex=1, col=hgreen)
  mtext("Line 3", side=3, line=3, adj=1.0, cex=1, col=hgreen)
  mtext("Line 0", side=2, line=0, adj=1.0, cex=1, col=hgreen)
  mtext("Line 1", side=2, line=1, adj=1.0, cex=1, col=hgreen)
  mtext("Line 2", side=2, line=2, adj=1.0, cex=1, col=hgreen)
  mtext("Line 3", side=2, line=3, adj=1.0, cex=1, col=hgreen)
  box("figure", col=hgreen)

  # Label the outer margin area and color it blue
  # Note the 'outer=TRUE' command moves us from the figure margins to the outer
  # margins.
  mtext("Outer Margin Area", side=1, line=1, cex=2, col=horange, outer=TRUE)
  mtext("par(oma=c(3,3,3,3))", side=1, line=2, cex=1, col=horange, outer=TRUE)
  mtext("Line 0", side=1, line=0, adj=0.0, cex=1, col=horange, outer=TRUE)
  mtext("Line 1", side=1, line=1, adj=0.0, cex=1, col=horange, outer=TRUE)
  mtext("Line 2", side=1, line=2, adj=0.0, cex=1, col=horange, outer=TRUE)
  box("outer", col=horange)

  usr <- par("usr")
  # inner <- par("inner")
  fig <- par("fig")
  plt <- par("plt")

  # text("Figure", x=fig, y=ycoord, adj = c(1, 0))
  text("Inner", x=usr[2] + (usr[2] - usr[1])/(plt[2] - plt[1]) * (1 - plt[2]),
       y=usr[3] - diff(usr[3:4])/diff(plt[3:4]) * (plt[3]), adj = c(1, 0))
  #text("Plot", x=usr[1], y=usr[2], adj = c(0, 1))

  figusrx <- grconvertX(usr[c(1,2)], to="nfc")
  figusry <- grconvertY(usr[c(3,4)], to="nfc")
  points(x=figusrx[c(1,1,2,2)], y=figusry[c(3,4,3,4)], pch=15, cex=3, xpd=NA)

  points(x=usr[c(1,1,2,2)], y=usr[c(3,4,3,4)], pch=15, col=hred, cex=2, xpd=NA)

  arrows(x0 = par("usr")[1], 8, par("usr")[2], 8, col="black", cex=2, code=3, angle = 15, length = .2)
  text(x = mean(par("usr")[1:2]), y=8.2, labels = "pin[1]", adj=c(0.5, 0))

}






.SimpEntryDlg <- function(text, default, main){
  
  requireNamespace("tcltk", quietly = FALSE)
  
  e1 <- environment()
  txt <- character()
  
  tfpw <- tcltk::tclVar("")
  
  OnOK <- function() {
    assign("txt", tcltk::tclvalue(tfpw), envir = e1)
    tcltk::tkdestroy(root)
  }
  
  # do not update screen
  tcltk::tclServiceMode(on = FALSE)
  
  # create window
  root <- .initDlg(205, 110, resizex=FALSE, resizey=FALSE, main=main, ico="R")
  
  # define widgets
  content <- tcltk::tkframe(root, padx=10, pady=10)
  tfEntrPW <- tcltk::tkentry(content, width="30", textvariable=tfpw)
  tfButOK <- tcltk::tkbutton(content,text="OK", command=OnOK, width=6)
  tfButCanc <- tcltk::tkbutton(content, text="Cancel", width=7,
                               command=function() tcltk::tkdestroy(root))
  
  # build GUI
  tcltk::tkgrid(content, column=0, row=0)
  tcltk::tkgrid(tcltk::tklabel(content, text=text), column=0, row=0,
                columnspan=3, sticky="w")
  tcltk::tkgrid(tfEntrPW, column=0, row=1, columnspan=3, pady=10)
  tcltk::tkgrid(tfButOK, column=0, row=2, ipadx=15, sticky="w")
  tcltk::tkgrid(tfButCanc, column=2, row=2, ipadx=5, sticky="e")
  
  # binding event-handler
  tcltk::tkbind(tfEntrPW, "<Return>", OnOK)
  
  tcltk::tkfocus(tfEntrPW)
  tcltk::tclServiceMode(on = TRUE)
  
  tcltk::tcl("wm", "attributes", root, topmost=TRUE)
  
  tcltk::tkwait.window(root)
  
  return(txt)
  
}





# == internal helper functions =============================================


.getImg <- function(fname){
  
  # looks for files either in /extdata  or in /inst/extdata
  
  path <- find.package("swissButler")
  
  res <- file.path(path, "extdata", fname)
  if(file.exists(res))
    return(res)
  
  res <- file.path(path, "inst","extdata", fname)
  if(file.exists(res))
    return(res)
  
  warning(gettextf("File %s not found in package folders."))
  
}


.bringToFront <- function(main){
  
  info_sys <- Sys.info() # sniff the O.S.
  
  if (info_sys['sysname'] == 'Windows') { # MS Windows trick
    shell(gettextf("powershell -command [void] [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') ; [Microsoft.VisualBasic.Interaction]::AppActivate('%s') ", main))
  }
  
}
