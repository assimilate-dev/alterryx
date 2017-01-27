#' Get Request URL
#'
#' This provides a manual way to access Alteryx Gallery endpoints
#' but in general the specific endpoint functions should be used
#' @param gallery The url for your Alteryx Gallery
#' @param endpoint The api endpoint beginning and ending with "/"
#' @param request_method HTTP request verb
#' @param request_params List of request parameters
#' @export
get_request_url <- function(gallery,
                            endpoint,
                            request_method,
                            request_params) {
  required_headers <- make_required_headers()
  oauth_signature <- make_signature(gallery,
                                    endpoint,
                                    request_method,
                                    required_headers,
                                    request_params)
  params <- append(required_headers, request_params)
  params <- append(params, list(oauth_signature = oauth_signature))
  params <- params[sort(names(params))]
  params <- paste0(names(params), '=', params, collapse = '&')
  request_url <- paste0(gallery, endpoint, '?', params)

  return(request_url)
}

#' Submit Request
#'
#' @inheritParams get_request_url
submit_request <- function(gallery,
                           endpoint,
                           request_method,
                           request_params) {
  request_url <-
    get_request_url(gallery, endpoint, request_method, request_params)
  response <- httr::GET(request_url)
  response <- check_status(response)
  content <- httr::content(response)

  return(content)
}

#' Get Subscriptions
#'
#' Get the workflows in a subscription. Subscription is tied to API key. You
#' cannot request workflows for any other subscription without that
#' subscription's key.
#'
#' @inheritParams get_request_url
#' @export
get_subscriptions <- function(gallery, request_params = list()) {
  request_method <- "GET"
  endpoint <- "/api/v1/workflows/subscription/"

  content <- submit_request(gallery,
                            endpoint,
                            request_method,
                            request_params)

  return(content)
}

#' Get App Questions
#'
#' Get the questions for the given Alteryx Analtytics App. Only app workflows
#' can be used.
#'
#' @inheritParams get_request_url
#' @param app_id ID of the app for which you want to retrieve the questions
#' @export
get_app_questions <- function(gallery, app_id) {
  request_method <- "GET"
  request_params <- list()
  endpoint <- "/api/v1/workflows/{appId}/questions/"
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_request(gallery,
                            endpoint,
                            request_method,
                            request_params)

  return(content)
}


#' Get App Jobs
#'
#' Returns the jobs for the given Alteryx Analtytics App. Only app workflows
#' can be used.
#'
#' @inheritParams get_request_url
#' @inheritParams get_app_questions
#' @export
get_app_jobs <- function(gallery, app_id, request_params = list()) {
  request_method <- "GET"
  endpoint <- "/api/v1/workflows/{appId}/jobs/"
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  content <- submit_request(gallery,
                            endpoint,
                            request_method,
                            request_params)

  return(content)
}

#' Get Job
#'
#' Retrieves the job and its current state. Only app workflows can be used.
#'
#' @inheritParams get_request_url
#' @param job_id The ID of the job to retrieve.
#' @export
get_job <- function(gallery, job_id, request_params) {
  request_method <- "GET"
  endpoint <- "/api/v1/jobs/{jobId}/"
  endpoint <- gsub("\\{jobId\\}", job_id, endpoint)

  content <- submit_request(gallery,
                            endpoint,
                            request_method,
                            request_params)

  return(content)
}

#' Get Job Output
#'
#' Returns output for a given job. Only app workflows can be used.
#'
#' @inheritParams get_job
#' @param output_id The ID for the output you want to retrieve.
#' @export
get_job_output <- function(gallery, job_id, output_id, request_params) {
  request_method <- "GET"
  endpoint <- "/api/v1/jobs/{jobId}/output/{outputId}/"
  endpoint <- gsub("\\{jobId\\}", job_id, endpoint)
  endpoint <- gsub("\\{outputId\\}", output_id, endpoint)

  content <- submit_request(gallery,
                            endpoint,
                            request_method,
                            request_params)

  return(content)
}

# queue_app <- function(gallery, app_id, values) {
#   request_method <- "POST"
#   endpoint <- "/api/v1/workflows/{appId}/jobs/"
#   endpoint <- gsub("\\{appId\\}", app_id, endpoint)
#
# }
