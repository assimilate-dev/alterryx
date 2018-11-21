`%||%` <- function(x, y) ifelse(is.null(x), y, x)

#' Get Gallery
#'
#' Remove '/' from the end of the Gallery URL
get_gallery <- function() {

  gallery <- getOption("alteryx_gallery")
  last_char <- substr(gallery, nchar(gallery), nchar(gallery))

  if(last_char == "/")
    gallery <- substr(gallery, 1, nchar(gallery) - 1)

  return(gallery)

}

#' Get Priority
#'
#' Translate Gallery priority text to appropriate value
#'
#' @param priority A value of 'low', 'medium', 'high', or 'critical' to be
#' translated into the appropriate integer value for job priority
get_priority <- function(priority) {
  priority_int <- switch(priority,
                         low = "0",
                         medium = "1",
                         high = "2",
                         critical = "3")

  if(is.null(priority_int)) {
    warning("Invalid priority: '", priority,
            "'. Priority automatically set to 'low'")

    priority_int <- "0"
  }

  return(priority_int)
}

#' Get Worker
#'
#' Get the tag for the worker assigned to run the app or job
#'
#' @param resource An alteryx app or job
get_worker <- function(resource) {
  is_app <- is.alteryx_app(resource)
  is_job <- is.alteryx_job(resource)

  if(is_app | is_job) {
    worker <- resource["workerTag"]
  } else {
    stop("Incorrect resource type. Cannot retrieve worker info")
  }

  return(worker)
}

#' Empty Answer
#'
#' Utility function used to queue a job for an app that has no questions
#'
#' @examples
#' \dontrun{
#' job <- queue_job(app, answer = empty_answer())
#' }
#'
#' @export
empty_answer <- function() build_answers(list())
