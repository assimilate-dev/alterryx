#' @title Alteryx Applications (Admin)
#'
#' @description Handling of application resources returned by the Alteryx
#' Gallery Admin API. For more information, see \code{\link{get_app_admin}}
#'
#' @exportClass alteryx_app_admin
#' @rdname alteryx_app_admin
#

#' @rdname alteryx_app_admin
#'
#' @param x A \code{list} of values pertaining to an Alteryx app returned from
#' the Alteryx Gallery Admin API
#'
#' @export
as.alteryx_app_admin <- function(x) {

  # alteryx_app_admin only checks for names because, unlike alteryx_app
  # sometimes values are returned as NULL instead of their proper type
  # i don't have time to figure this out so for now i am implementing
  # a less restrictive test
  expected <- c("fileName", "id")

  x_names <- names(x)
  if(!all(expected %in% x_names))
    stop("Unexpected input. Cannot convert to type alteryx_app_admin.")

  class(x) <- append("alteryx_app_admin", class(x))
  return(x)
}

#' @rdname alteryx_app_admin
#'
#' @param object An R object
#'
#' @export
is.alteryx_app_admin <- function(object) inherits(object, "alteryx_app_admin")

#' @export
format.alteryx_app_admin <- function(x, ...) {
  paste(
    paste("App Name:", x$fileName),
    paste("App ID:", x$id),
    sep = "\n"
  )
}

#' @export
print.alteryx_app_admin <- function(x, ...) cat(format(x, ...), "\n")

#' @export
get_info.alteryx_app_admin <- function(resource, full_info = FALSE) {

  if(full_info) {

    info <- lapply(names(resource), function(x) {resource[[x]]})
    names(info) <- names(resource)

  } else {

    info_names <- names(resource)
    exclude <- c("metaInfo", "collections", "publishedVersionOwner")
    info_names <- info_names[!info_names %in% exclude]

    info <- lapply(info_names, function(x) {resource[[x]]})
    names(info) <- info_names

  }

  return(info)

}
