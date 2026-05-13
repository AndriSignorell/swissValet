
# -------------------------------------------------------------------------
# insert selected object as source code
# -------------------------------------------------------------------------

#' Insert selected object as reproducible R code
#'
#' Converts the currently selected object in the RStudio editor into
#' reproducible R source code and inserts it into the active document.
#'
#' Data frames are converted into a readable `data.frame(...)`
#' representation instead of the more verbose `dput()` structure output.
#'
#' Other objects are serialized using [base::dput()].
#'
#' @param width.cutoff Integer. Passed to [base::deparse()].
#'
#' @return
#' Invisibly returns the generated code.
#'
#' @examples
#' \dontrun{
#' flushToSource()
#' }
#'


#' @export
flushToSource <- function(width.cutoff = 500L) {
  
  sel <- rstudioapi::getActiveDocumentContext()$
    selection[[1]]$text
  
  if (!nzchar(sel)) {
    cli::cli_alert_warning("No selection.")
    return(invisible(NULL))
  }
  
  obj <- tryCatch(
    eval(
      parse(text = sel),
      envir = .GlobalEnv
    ),
    error = function(e) {
      cli::cli_alert_danger(
        "Could not evaluate selection."
      )
      return(NULL)
    }
  )
  
  if (is.null(obj))
    return(invisible(NULL))
  
  txt <- .objAsCode(
    obj,
    width.cutoff = width.cutoff
  )
  
  out <- paste0(
    sel,
    " <- ",
    txt,
    "\n"
  )
  
  rstudioapi::insertText(out)
  
  invisible(out)
}




# == internal helper functions ================================================


# -------------------------------------------------------------------------
# format data.frame as readable R code
# -------------------------------------------------------------------------
#' @keywords internal
.dfAsCode <- function(x,
                      row.names = FALSE,
                      width.cutoff = 500L,
                      indent = 2L) {
  
  stopifnot(is.data.frame(x))
  
  spc <- strrep(" ", indent)
  
  cols <- lapply(names(x), function(nm) {
    
    val <- paste(
      deparse(
        x[[nm]],
        width.cutoff = width.cutoff,
        control = NULL
      ),
      collapse = "\n"
    )
    
    sprintf(
      "%s = %s",
      nm,
      val
    )
  })
  
  if (row.names && !is.null(rownames(x))) {
    
    rn <- paste(
      deparse(
        rownames(x),
        width.cutoff = width.cutoff
      ),
      collapse = "\n"
    )
    
    cols <- c(
      cols,
      sprintf("row.names = %s", rn)
    )
  }
  
  txt <- paste0(
    "data.frame(\n",
    spc,
    paste(cols, collapse = paste0(",\n", spc)),
    "\n)"
  )
  
  txt
}



# -------------------------------------------------------------------------
# generic object -> code
# -------------------------------------------------------------------------
#' @keywords internal
.objAsCode <- function(x,
                       width.cutoff = 500L) {
  
  if (is.data.frame(x)) {
    
    .dfAsCode(
      x,
      width.cutoff = width.cutoff
    )
    
  } else {
    
    paste(
      capture.output(
        dput(
          x,
          control = NULL
        )
      ),
      collapse = "\n"
    )
  }
}

