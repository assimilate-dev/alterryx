#' Get Resource Information
#'
#' Retrieves all metadata about an Alteryx resource including but not limited
#' to upload date, version, and author
#'
#' @param resource An Alteryx \code{app} or \code{job}
#' @param full_info If \code{TRUE}, returns all info retrieved from Gallery.
#' The default, \code{FALSE}, removes extraneous information to make it
#' easier to read.
#'
#' @examples
#' \dontrun{
#' job <- queue_job(app, answers)
#' get_info(job)
#' }
#'
#' @export
get_info <- function(resource, full_info = FALSE) UseMethod("get_info")

#' Job Log
#'
#' Retrieve the log messages for a "Completed" job
#'
#' @param job An completed Alteryx job returned from \code{get_job}
#'
#' @export
get_job_log <- function(job) {
  if(job$status != "Completed")
    stop("Job not complete. Cannot get log.")
  if(!length(job$messages))
    stop("Job has no log.")

  messages <- lapply(job$messages, function(x) {
    data.frame(x, stringsAsFactors = FALSE)[c("toolId", "text")]
  })
  messages <- do.call(rbind, messages)

  return(messages)
}


