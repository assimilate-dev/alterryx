add_parent <- function(parent, alteryx_job) {
  parent <- list(parentApp = parent$fileName %||% parent$parentApp,
                 parentId = parent$id %||% parent$parentId)

  alteryx_job <- append(parent, alteryx_job)
  return(alteryx_job)
}

alteryx_job <- function(x) {
  expected <- list(parentApp = "character",
                   parentId = "character",
                   id = "character",
                   createDate = "character",
                   status = "character",
                   disposition = "character",
                   outputs = "list",
                   messages = "list")

  x_class <- lapply(x, class)
  if(!identical(x_class, expected))
    stop("Unexpected input. Cannot convert to type alteryx_job.")

  class(x) <- append("alteryx_job", class(x))
  return(x)
}

is.alteryx_job <- function(x) inherits(x, "alteryx_job")

#' @export
format.alteryx_job <- function(x, ...) {
  paste0("job for ", x$parentApp, ", job_id:", x$id, ", status:", x$status)
}

#' @export
print.alteryx_job <- function(x, ...) cat(format(x, ...), "\n")
