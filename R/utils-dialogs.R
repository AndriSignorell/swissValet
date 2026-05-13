


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
.getImg <- function(fname){
  
  # looks for files either in /extdata  or in /inst/extdata
  path <- find.package(.thisPackage())
  
  res <- file.path(path, "extdata", fname)
  if(file.exists(res))
    return(res)
  
  res <- file.path(path, "inst","extdata", fname)
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

