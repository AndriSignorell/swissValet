

.onLoad <- function(libname, pkgname) {
  
  # # presetting DescTools options not already defined by the user
  # op <- options()
  # 
  # pkg.op <- list(
  #   DescToolsX.lastWrd   = NULL,
  #   DescToolsX.lastXL    = NULL,
  #   DescToolsX.lastPP    = NULL
  # )
  # 
  # toset <- !(names(pkg.op) %in% names(op))
  # if (any(toset)) options(pkg.op[toset])
  
}


#' @importFrom tcltk tkgetSaveFile tclvalue ttkcombobox tkconfigure tclVar tclvalue<- tkbind tkbutton tkcanvas tkcreate tkdelete tkdestroy tkentry tkfocus tkframe tkgrab.set tkgrid tkimage.create tklabel tkpack tktoplevel tkwait.window tkwm.title tkfocus

#' @importFrom grDevices col2rgb colors dev.cur dev.list dev.new dev.off dev.set png rgb2hsv
 
#' @importFrom graphics arrows box grconvertX grconvertY mtext par plot.new points polygon segments text
 
#' @importFrom utils capture.output edit object.size select.list

#' @importFrom aurora fm strTrim strExtract strTrunc pal
#' @importFrom bedrock label strX splitPath
#' @importFrom cli cli_alert_info cli_alert_success cli_alert_danger
#' @importFrom writexl write_xlsx
#' @importFrom clipr write_clip
NULL           


