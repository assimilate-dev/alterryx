unlist_if_short <- function(l) {
  if(length(l) == 1) l[[1]] else l
}

`%||%` <- function(x, y) ifelse(is.null(x), y, x)

#' @export
get_info <- function(alteryx_object) {
  as.list(alteryx_object)
}
