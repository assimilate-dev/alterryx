#' Generate Nonce
make_nonce <- function() {
  #random::randomStrings(n = 1, len = 20, upperalpha = FALSE)[1]
  basename(tempfile(pattern = ""))
}

#' Generate Required Headers
#'
#' Alteryx Gallery requests require headers consumer_key, signature_method,
#' timestamp, nonce, and version.
make_required_headers <- function() {
  oauth_nonce <- make_nonce()
  oauth_timestamp <- as.character(as.integer(Sys.time()))
  required_headers <- list(
    oauth_consumer_key = getOption("alteryx_api_key"),
    oauth_signature_method = "HMAC-SHA1",
    oauth_timestamp = oauth_timestamp,
    oauth_nonce = oauth_nonce,
    oauth_version = "1.0"
  )

  return(required_headers)
}

#' Make Base Url
#'
#' Create and url encode the base url
#' @inheritParams make_signature
make_base_url <- function(gallery, endpoint) {
  base_url <- paste0(gallery, endpoint)
  base_url <- utils::URLencode(base_url)

  return(base_url)
}

#' Normalize Request Parameters
#'
#' Combine, sort, and url encode headers and param list
#' @param required_headers Required headers created with
#' \code{make_required_headers}
#' @param request_params List of request parameters
normalize_request_params <- function(required_headers,
                                     request_params) {
  request_params <- append(required_headers,
                           request_params)
  request_params <- encode_list(request_params)
  request_params <- request_params[sort(names(request_params))]
  request_params <-
    paste0(names(request_params), "=", request_params, collapse = "&")

  return(request_params)
}

#' Make Base String
#'
#' Create the base string to be signed
#' @param request_method HTTP request verb
#' @param base_url Base url created with \code{make_base_url}
#' @param normalized_request_params Normalized request parameters created with
#' \code{normalize_request_params}
make_base_string <- function(request_method,
                             base_url,
                             normalized_request_params) {
  base_string <- list(request_method,
                      base_url,
                      normalized_request_params)
  base_string <- encode_list(base_string)
  base_string <- paste(paste(base_string), collapse = "&")

  return(base_string)
}

#' Sign Base String
#'
#' @param base_string base string created with \code{make_base_string}
sign_base_string <- function(base_string) {
  signing_key <- paste0(getOption("alteryx_secret_key"), "&")
  signature <-
    digest::hmac(signing_key, base_string, algo = "sha1", raw = TRUE)
  signature <- base64enc::base64encode(signature)
  signature <- utils::URLencode(signature, reserved = TRUE)

  return(signature)
}

#' Make Signature
#'
#' @param gallery The url an Alteryx Gallery
#' @param endpoint The api endpoint beginning and ending with "/"
#' @param request_method HTTP request verb
#' @param required_headers Required headers created with
#' \code{make_required_headers}
#' @param request_params List of request parameters
make_signature <- function(gallery,
                           endpoint,
                           request_method,
                           required_headers,
                           request_params) {
  base_url <- make_base_url(gallery, endpoint)
  normalized_request_params <-
    normalize_request_params(required_headers, request_params)
  base_string <-
    make_base_string(request_method,
                     base_url,
                     normalized_request_params)
  signature <- sign_base_string(base_string)

  return(signature)
}
