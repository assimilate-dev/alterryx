#' Get Resource Information
#'
#' Retrieves all metadata about an Alteryx resource including but not limited
#' to upload date, version, and author
#'
#' @param resource An Alteryx \code{app} or \code{job}
#'
#' @examples
#' \dontrun{
#' job <- queue_job(app, answers)
#' get_info(job)
#' }
#'
#' @export
get_info <- function(resource) {
  info <- lapply(names(resource), function(x) {resource[[x]]})
  names(info) <- names(resource)

  return(info)
}

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

  messages <- lapply(get_info(job)$messages, function(x) {
    data.frame(x, stringsAsFactors = FALSE)[c("toolId", "text")]
  })
  messages <- do.call(rbind, messages)

  return(messages)
}


