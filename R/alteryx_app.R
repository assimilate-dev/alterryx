alteryx_app <- function(x) {
  expected <- list("id" = "character",
                   "subscriptionId" = "character",
                   "public" = "logical",
                   "runDisabled" = "logical",
                   "packageType" = "integer",
                   "uploadDate" = "character",
                   "fileName" = "character",
                   "metaInfo" = "list",
                   "isChained" = "logical",
                   "version" = "integer",
                   "runCount" = "integer")

  x_class <- lapply(x, class)
  if(!identical(x_class, expected))
    stop("Unexpected input. Cannot convert to type alteryx_app.")

  class(x) <- append("alteryx_app", class(x))
  return(x)
}

is.alteryx_app <- function(x) inherits(x, "alteryx_app")

#' @export
format.alteryx_app <- function(x, ...) {
  paste0(x$fileName, ", app_id:", x$id)
}

#' @export
print.alteryx_app <- function(x, ...) cat(format(x, ...), "\n")
