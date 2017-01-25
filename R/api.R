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

#' Get Subscriptions
#'
#' Get the workflows in a subscription. Subscription is tied to API key. You
#' cannot request workflows for any other subscription without that
#' subscription's key.
#'
#' @inheritParams get_request_url
#' @export
get_subscriptions <- function(gallery, request_params) {
  request_method <- "GET"
  endpoint <- "/api/v1/workflows/subscription/"

  request_url <-
    get_request_url(gallery, endpoint, request_method, request_params)
  response <- httr::GET(request_url)

  return(response)
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

  request_url <-
    get_request_url(gallery, endpoint, request_method, request_params)
  response <- httr::GET(request_url)

  return(response)
}
