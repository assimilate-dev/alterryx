#' URL Encode List
#'
#' URL encode all values in a list using \code{utils::URLencode()}
#' @param l a list
#' @param reserved logical: should ‘reserved’ characters be encoded?
encode_list <- function(l, reserved = TRUE) {
  lapply(l, function(x) {
    utils::URLencode(x, reserved = reserved)
  })
}
