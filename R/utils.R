`%||%` <- function(x, y) ifelse(is.null(x), y, x)

#' Get Gallery
#'
#' Remove '/' from the end of the Gallery URL
get_gallery <- function() {

  gallery <- getOption("alteryx_gallery")
  last_char <- substr(gallery, nchar(gallery), nchar(gallery))

  if(last_char == '/')
    gallery <- substr(gallery, 1, nchar(gallery) - 1)

  return(gallery)

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
