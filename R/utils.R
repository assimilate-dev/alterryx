`%||%` <- function(x, y) ifelse(is.null(x), y, x)

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
