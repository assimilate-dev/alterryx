#' Get Subscriptions
#'
#' Get the workflows in a subscription. Subscription is tied to API key. You
#' cannot request workflows for any other subscription without that
#' subscription's key.
#'
#' @inheritParams submit_get_request
#' @export
get_apps <- function(gallery, request_params = list()) {
  endpoint <- "/api/v1/workflows/subscription/"

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  if(length(content)) {
    content <- lapply(content, alteryx_app)
  } else {
    content <- NULL
  }

  return(content)
}

#' Get App Questions
#'
#' Get the questions for the given Alteryx Analtytic App. Only app workflows
#' can be used.
#' @inheritParams submit_get_request
#' @param app_id ID of the app for which you want to retrieve the questions
#' @export
get_app_questions <- function(gallery, app) {
  if(!is.alteryx_app(app))
    stop("argument 'app' must be an object of class 'alteryx_app")

  request_params <- list()
  app_id <- app$id
  endpoint <- "/api/v1/workflows/{appId}/questions/"
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  return(content)
}

#' Get App Jobs
#'
#' Returns the jobs for the given Alteryx Analtytics App. Only app workflows
#' can be used.
#' @inheritParams get_app_questions
#' @inheritParams submit_get_request
#' @export
get_app_jobs <- function(gallery, app_id, request_params = list()) {
  endpoint <- "/api/v1/workflows/{appId}/jobs/"
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  return(content)
}

#' Get Job
#'
#' Retrieves the job and its current state. Only app workflows can be used.
#' @inheritParams submit_get_request
#' @param job_id The ID of the job to retrieve
#' @export
get_job <- function(gallery, job, request_params = list()) {
  if(!is.alteryx_job(job))
    stop("argument 'job' must be an object of class 'alteryx_job")

  endpoint <- "/api/v1/jobs/{jobId}/"
  job_id <- job$id
  endpoint <- gsub("\\{jobId\\}", job_id, endpoint)

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  content <- add_parent(job, content)
  content <- alteryx_job(content)

  return(content)
}

#' Get Job Output
#'
#' Returns output for a given job. Only app workflows can be used.
#' @inheritParams get_job
#' @param output_id The ID for the output you want to retrieve.
#' @export
get_job_output <- function(gallery, job, request_params = list()) {
  if(job$status != "Completed")
    stop("Job not complete. Cannot get output.")
  if(!length(job$outputs))
    stop("Job has no output.")

  endpoint <- "/api/v1/jobs/{jobId}/output/{outputId}/"
  job_id <- job$id
  output_id <- lapply(job$outputs, function(x) {x$id})
  endpoint <- gsub("\\{jobId\\}", job_id, endpoint)
  endpoint <- lapply(output_id, function(x) {
    gsub("\\{outputId\\}", x, endpoint)
  })

  content <-lapply(endpoint, function(x) {
    submit_get_request(gallery,
                       endpoint,
                       request_params,
                       as = "raw",
                       remove_bom = FALSE,
                       parse_JSON = FALSE)
  })

  return(content)
}

#' Build Request Body
#'
#' Build the JSON of name value pairs corresponding to app questions for
#' @param name_value \code{list} containing an app question \code{name} and
#' \code{value} pair
#' @param ... Additional \code{name_value} pairs
#' @export
#' @examples
#' first_question <- list(name = "a", value = "1")
#' second_question <- list(name = "b", value = "2")
#' build_request_body(first_question, second_question)
build_request_body <- function(name_value, ...) {
  questions <- list(name_value, ...)
  jsonlite::toJSON(list(questions = questions), auto_unbox = TRUE)
}

#' Queue Job
#'
#' Queue a job for an application
#' @return Returns the ID of the job. Use the status request to get the results
#' of the job.
#' @inheritParams submit_post_request
#' @param app_id ID of an app for which to queue a job
#' @export
post_app_job <- function(gallery, app, request_body) {
  if(!is.alteryx_app(app))
    stop("argument 'app' must be an object of class 'alteryx_app")

  request_params <- list()
  app_id <- app$id
  endpoint <- "/api/v1/workflows/{appId}/jobs/"
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_post_request(gallery,
                                 endpoint,
                                 request_params,
                                 request_body)

  content <- add_parent(app, content)
  content <- alteryx_job(content)

  return(content)
}
