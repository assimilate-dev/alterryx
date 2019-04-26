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

#' Get Migration Default Form
#'
#' Utility function to extract app info to populate migration form defaults
#'
#' @param app A single \code{alteryx_app} returned from \code{get_app}
get_migration_form <- function(app) {

  form <- list(
    name = app$metaInfo$name,
    owner = app$publishedVersionOwner$email,
    validate = "false",
    isPublic = "false",
    sourceId = app$id,
    workerTag = app$workerTag,
    canDownload = "false"
  )

  return(form)

}

#' Cat Paste
#'
#' For when you need to paste your cats
#'
#' @param ... Things to paste on your cat
cat_paste <- function(...) {
  cat(
    paste(
      ...
    )
  )
}
