


.extract_xy <- function(sel, parent = parent.frame()) {
  
  if (getOption("debug", FALSE)) {
    print(sel)
  }
  
  if (!nzchar(trimws(sel))) {
    stop("Please select plot output or arguments.")
  }
  
  # -------------------------
  # 1. Versuch: direkt parsen
  # -------------------------
  expr <- try(parse(text = sel)[[1]], silent = TRUE)
  
  is_full_expr <- !inherits(expr, "try-error")
  
  # -------------------------
  # Fall A: vollständiger Ausdruck (z.B. with(...))
  # -------------------------
  if (is_full_expr) {
    
    if (.contains_plot_call(expr)) {
      
      env <- new.env(parent = parent)
      
      env$plot <- function(x, y, ...) {
        assign(".__xy__", list(x = x, y = y), envir = env)
        invisible(NULL)
      }
      
      eval(expr, envir = env)
      
      if (exists(".__xy__", envir = env)) {
        return(get(".__xy__", envir = env))
      }
    }
  }
  
  # -------------------------
  # Fall B: Fragment → plot() drumherum bauen
  # -------------------------
  call <- parse(text = paste0("plot(", sel, ")"))[[1]]
  
  # Formel?
  if (inherits(call[[2]], "formula")) {
    
    call[[1]] <- quote(stats::model.frame)
    
    opt <- options(na.action = "na.pass")
    on.exit(options(opt))
    
    mf <- eval(call, parent)
    
    response <- attr(attr(mf, "terms"), "response")
    
    return(list(
      x = mf[[-response]],
      y = mf[[response]]
    ))
  }
  
  # x,y
  x <- eval(call[[2]], parent)
  y <- eval(call[[3]], parent)
  
  return(list(x = x, y = y))
}

