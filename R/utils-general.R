


#' @keywords internal
.thisPackage <- function() {
  ns <- topenv(environment())
  
  if (identical(ns, globalenv())) {
    return(NULL)
  }
  
  tryCatch(
    getNamespaceName(ns),
    error = function(e) NULL
  )
}




#' @keywords internal
.removeAddIn <- function(pkg) {
  
  stopifnot(length(pkg) == 1L)
  
  pkg_path <- find.package(pkg)
  
  addin_file <- file.path(
    pkg_path,
    "rstudio",
    "addins.dcf"
  )
  
  if (!file.exists(addin_file)) {
    cli::cli_alert_info(
      "No addins.dcf found."
    )
    return(FALSE)
  }
  
  ok <- file.remove(addin_file)
  
  if (ok) {
    cli::cli_alert_success(
      "Removed {.file addins.dcf}"
    )
  } else {
    cli::cli_alert_danger(
      "Could not remove {.file addins.dcf}"
    )
  }
  
  invisible(ok)
}


