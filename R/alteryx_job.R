#' @title Alteryx Jobs
#'
#' @description Handling of job information returned by the Alteryx
#' Gallery API. For more information, see \code{\link{get_job}}.
#'
#' @exportClass alteryx_job
#'
#' @rdname alteryx_job
#

#' @rdname alteryx_job
#'
#' @param x A \code{list} of values pertaining to an Alteryx job returned from
#' the Alteryx Gallery API
#' @param parent An \code{alteryx_app} or \code{alteryx_job} containing the id
#' and name information of the parent application for a job.
#'
#' @export
as.alteryx_job <- function(x, parent) {
  add_parent <- function(job, parent) {
    parent <- list(parentApp = parent$fileName %||% parent$parentApp,
                   parentId = parent$id %||% parent$parentId)

    alteryx_job <- append(job, parent)
    return(alteryx_job)
  }

  x <- add_parent(x, parent)

  expected <- list(parentApp = "character",
                   parentId = "character",
                   id = "character",
                   createDate = "character",
                   status = "character",
                   disposition = "character",
                   outputs = "list",
                   messages = "list")

  expected <- expected[sort(names(expected))]
  x <- x[sort(names(x))]

  x_class <- lapply(x, class)
  if(!identical(x_class, expected))
    stop("Unexpected input. Cannot convert to type alteryx_job.")

  class(x) <- append("alteryx_job", class(x))
  return(x)
}

#' @rdname alteryx_job
#'
#' @param object An R object
#'
#' @export
is.alteryx_job <- function(object) inherits(object, "alteryx_job")

#' @export
format.alteryx_job <- function(x, ...) {
  paste0("job for ", x$parentApp, ", job_id:", x$id, ", status:", x$status)
}

#' @export
print.alteryx_job <- function(x, ...) cat(format(x, ...), "\n")
