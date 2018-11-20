#' @title Alteryx Applications
#'
#' @description Handling of application resources returned by the Alteryx
#' Gallery API. For more information, see \code{\link{get_app}}
#'
#' @exportClass alteryx_app
#' @rdname alteryx_app
#

#' @rdname alteryx_app
#'
#' @param x A \code{list} of values pertaining to an Alteryx app returned from
#' the Alteryx Gallery API
#'
#' @export
as.alteryx_app <- function(x) {

  expected <- list(id = "character",
                   subscriptionId = "character",
                   public = "logical",
                   runDisabled = "logical",
                   packageType = "integer",
                   uploadDate = "character",
                   fileName = "character",
                   metaInfo = "list",
                   isChained = "logical",
                   version = "integer",
                   runCount = "integer",
                   workerTag = "character")

  x_class <- lapply(x, class)
  if(!identical(x_class, expected))
    stop("Unexpected input. Cannot convert to type alteryx_app.")

  class(x) <- append("alteryx_app", class(x))
  return(x)
}

#' @rdname alteryx_app
#'
#' @param object An R object
#'
#' @export
is.alteryx_app <- function(object) inherits(object, "alteryx_app")

#' @export
format.alteryx_app <- function(x, ...) {
  paste(
    paste("App Name:", x$fileName),
    paste("App ID:", x$id),
    sep = "\n"
  )
}

#' @export
print.alteryx_app <- function(x, ...) cat(format(x, ...), "\n")

#' @export
get_info.alteryx_app <- function(resource, full_info = FALSE) {

  if(full_info) {

    info <- lapply(names(resource), function(x) {resource[[x]]})
    names(info) <- names(resource)

  } else {

    info_names <- names(resource)
    info_names <- info_names[!info_names %in% c("metaInfo")]

    info <- lapply(info_names, function(x) {resource[[x]]})
    names(info) <- info_names

  }

  return(info)

}
