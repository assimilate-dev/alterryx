#' Get Applications
#'
#' Get the workflows you can access from your studio (subscription).
#' Subscription is tied to API key. You cannot request workflows for any other
#' subscription without that subscription's API keys.
#'
#' @return A \code{list} of \code{alteryx_app}s
#'
#' @section WARNING:
#' \code{get_app} will return all resources in the Gallery tied to your
#' subscription including macros and workflows in addition to applications. You
#' cannot run workflows or macros using the Alteryx Gallery API and if you try
#' to do so you will receive an error.
#'
#' @param gallery URL for your Alteryx Gallery
#' @param request_params List of request parameters. For more information on
#' parameters, visit the Alteryx Gallery API documentation
#' \url{https://gallery.alteryx.com/api-docs/}
#'
#' @examples
#' \dontrun{
#' # get the five most recently uploaded apps in your studio
#'
#' request_params <- list(
#'   packageType = "0",
#'   limit = "5",
#'   sortField = "uploaddate"
#' )
#'
#' get_app(request_params)
#' }
#'
#' @export
get_app <- function(request_params = list(),
                    gallery = getOption("alteryx_gallery")) {
  endpoint <- "/api/v1/workflows/subscription/"

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  if(length(content)) {
    content <- lapply(content, as.alteryx_app)
  } else {
    content <- NULL
  }

  return(content)
}

#' Get App Questions
#'
#' @description Get the questions for the given Alteryx Analtytic App. Only app
#' workflows can be used.
#'
#' @details Most Alteryx apps have questions, user input that defines how
#' the application should run. The answers to these questions need to be sent
#' as \code{request_body} when queueing an application on Gallery with
#' \code{queue_job}. \code{get_app_questions} returns the names,
#' types, and default values of the questions for an app.
#'
#' @section WARNING:
#' Trees, Maps, and File Browse are unsupported question types. This is a
#' limitation of Alteryx Gallery and not this API client.
#'
#' @inheritParams get_app
#' @param app An \code{alteryx_app} returned from \code{\link{get_app}}
#'
#' @export
get_app_questions <- function(app,
                              gallery = getOption("alteryx_gallery")) {
  if(!is.alteryx_app(app))
    stop("argument 'app' must be an object of class 'alteryx_app")

  request_params <- list()
  endpoint <- "/api/v1/workflows/{appId}/questions/"
  app_id <- app$id
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  return(content)
}

#' Get App Jobs
#'
#' @description A job is a single run of an app. To queue a job for an app use
#' \code{queue_app}. Once queued, there are two ways to poll the gallery
#' for an update on the job status: \code{get_app_jobs} or \code{get_job}.
#'
#' \code{get_app_jobs} will return all jobs for a given app.
#' \code{get_job} will return a single job and is mostly used for polling the
#' status of a job.
#'
#' @section See Also:
#' Once a job is complete, use \code{\link{get_job_output}} to retrieve
#' the results.
#'
#' @inheritParams get_app
#' @param app An Alteryx app returned from \code{\link{get_app}}
#' @param job An Alteryx job returned from \code{get_app_jobs} or
#' \code{queue_jobs}
#'
#' @aliases get_app_jobs get_job
#'
#' @examples
#' \dontrun{
#' # get the five most recently queued jobs for an app
#' request_params <- list(
#'   sortField = "createdate",
#'   limit = "5"
#' )
#'
#' get_app_jobs(app, request_params)
#' }
#'
#' @name app_jobs
NULL

#' @rdname app_jobs
#'
#' @export
get_app_jobs <- function(app,
                         request_params = list(),
                         gallery = getOption("alteryx_gallery")) {
  if(!is.alteryx_app(app))
    stop("argument 'app' must be an object of class 'alteryx_app")

  endpoint <- "/api/v1/workflows/{appId}/jobs/"
  app_id <- app$id
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  return(content)
}

#' @rdname app_jobs
#'
#' @export
get_job <- function(job,
                    gallery = getOption("alteryx_gallery")) {
  if(!is.alteryx_job(job))
    stop("argument 'job' must be an object of class 'alteryx_job")

  request_params <- list()
  endpoint <- "/api/v1/jobs/{jobId}/"
  job_id <- job$id
  endpoint <- gsub("\\{jobId\\}", job_id, endpoint)

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  content <- as.alteryx_job(content, job)

  return(content)
}

#' Get Job Output
#'
#' @description If an Alteryx app includes one or more output tools inside the
#' application, the output will be available for download once the job is
#' complete.
#'
#' Use \code{get_job_output} to get the job outputs as a \code{data.frame}
#'
#' @section WARNING:
#' In order to retrieve the results for a job as a \code{data.frame}, the
#' from the Alteryx app that is published to your gallery must have an output
#' format of csv or yxdb. Otherwise, it cannot be properly converted. If you
#' have multiple outputs, some of which cannot be converted, this function will
#' issue a warning and skip the invalid outputs. Use \code{queit = TRUE} to
#' skip the outputs without warning.
#'
#' @return A \code{list} containing a \code{data.frame} for each valid output
#' of an Alteryx app. Valid means that the output can be converted as explained
#' in the WARNING section.
#'
#' @inheritParams get_app
#' @param job An completed Alteryx job returned from \code{get_app_jobs}
#' @param quiet Set to \code{TRUE} to ignore the warnings of skipped, invalid
#' outputs
#'
#' @export
get_job_output <- function(job,
                           gallery = getOption("alteryx_gallery"),
                           quiet = FALSE) {
  if(job$status != "Completed")
    stop("Job not complete. Cannot get output.")
  if(!length(job$outputs))
    stop("Job has no output.")

  outputs <- job$outputs
  valid_outputs <- lapply(outputs, function(x) {
    "Csv" %in% unlist(x$formats)
  })
  valid_outputs <- outputs[unlist(valid_outputs)]

  if(length(outputs) != length(valid_outputs) && !quiet)
    warning("All outputs not valid to read as a data.frame and will be skipped.
            See ??get_job_output for more information.")

  endpoint <- "/api/v1/jobs/{jobId}/output/{outputId}/"
  job_id <- job$id
  output_id <- lapply(valid_outputs, function(x) {x$id})
  endpoint <- gsub("\\{jobId\\}", job_id, endpoint)
  endpoint <- lapply(output_id, function(x) {
    gsub("\\{outputId\\}", x, endpoint)
  })

  request_params <- list(
    format = "Csv"
  )

  content <-lapply(endpoint, function(x) {
    submit_get_request(gallery,
                       x,
                       request_params,
                       as = "raw",
                       remove_bom = FALSE,
                       parse_JSON = FALSE)
  })

  job_output <- lapply(content, function(x) {
    read.csv(textConnection(rawToChar(x)))
  })

  return(job_output)
}

#' Queue Job for an App
#'
#' @description Each app has a set of questions that require an answer in order
#' to be run. The answers to the app questions are formatted using
#' \code{build_answers}. To see the required questions for an app use
#' \code{\link{get_app_questions}}.
#'
#' Use \code{\link{queue_job}} to queue a job for an app. A job is a single run
#' of an app run according to the answers submitted.
#'
#' @section See Also:
#' Use \code{\link{get_app}} to find apps to queue.
#'
#' Once a job has been queued, use \code{\link{get_job}} to poll the job and
#' check its status.
#'
#' @return An alteryx job with status "Queued"
#'
#' @inheritParams get_app
#' @param app An \code{alteryx_app} returned from \code{\link{get_app}}
#' @param answers Answers to required \code{app} questions created using
#' \code{build_answers}
#' @param name_value \code{list} containing an app question name and value pair
#' @param ... Additional \code{name_value} pairs
#'
#' @aliases queue_job build_answers
#'
#' @examples
#' \dontrun{
#' first_question <- list(name = "a", value = "1")
#' second_question <- list(name = "b", value = "2")
#' answers <- build_answers(first_question, second_question)
#'
#' new_job <- queue_job(app, answers)
#' }
#'
#' @name running_jobs
NULL

#' @rdname running_jobs
#'
#' @export
queue_job <- function(app,
                      answers,
                      gallery = getOption("alteryx_gallery")) {
  if(!is.alteryx_app(app))
    stop("argument 'app' must be an object of class 'alteryx_app")

  request_params <- list()
  app_id <- app$id
  endpoint <- "/api/v1/workflows/{appId}/jobs/"
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_post_request(gallery,
                                 endpoint,
                                 request_params,
                                 request_body = answers)

  content <- as.alteryx_job(content, app)

  return(content)
}

#' @rdname running_jobs
#'
#' @export
build_answers <- function(name_value, ...) {
  questions <- list(name_value, ...)
  jsonlite::toJSON(list(questions = questions), auto_unbox = TRUE)
}

#' Get Resource Information
#'
#' Retrieves all metadata about an Alteryx resource including but not limited
#' to upload date, version, and author
#'
#' @param resource An Alteryx \code{app} or \code{job}
#' @export
get_info <- function(resource) {
  info <- lapply(names(resource), function(x) {resource[[x]]})
  names(info) <- names(resource)

  return(info)
}
