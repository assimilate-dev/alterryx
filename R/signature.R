#' Percent encode all values in a list using \code{utils::URLencode}
#'
#' @param l A \code{list}
#' @param reserved logical: should ‘reserved’ characters be encoded?
encode_list <- function(l, reserved = TRUE) {
  lapply(l, function(x) {
    utils::URLencode(x, reserved = reserved)
  })
}

#' Generate Nonce
generate_nonce <- function() {
  basename(tempfile(pattern = ""))
}

#' Generate the request headers required by Alteryx Gallery
generate_required_headers <- function() {
  oauth_nonce <- generate_nonce()
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

#' Create and percent encode the base URL, part of the base string to be signed
#'
#' @inheritParams build_signature
build_base_url <- function(gallery, endpoint) {
  base_url <- paste0(gallery, endpoint)
  base_url <- utils::URLencode(base_url, reserved = TRUE)

  return(base_url)
}

#' Combine, sort, and percent encode headers and param list, part of the base
#' string to be signed
#'
#' @inheritParams build_signature
normalize_request_params <- function(required_headers,
                                     request_params) {
  request_params <- append(required_headers, request_params)
  request_params <- encode_list(request_params)
  request_params <- request_params[sort(names(request_params))]
  request_params <-
    paste0(names(request_params), "=", request_params, collapse = "&")

  return(request_params)
}

#' Create the base string to be signed
#'
#' @param request_method Character vector containing an HTTP request verb
#' @param base_url Base URL created with \code{build_base_url}
#' @param normalized_request_params Normalized request parameters created with
#' \code{normalize_request_params}
build_base_string <- function(request_method,
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
#' @param base_string Base string created with \code{build_base_string}
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
#' @param gallery URL of an Alteryx Gallery
#' @param endpoint API endpoint beginning and ending with "/"
#' @param request_method HTTP request verb
#' @param required_headers Required headers created with
#' \code{build_required_headers}
#' @param request_params List of request parameters
build_signature <- function(gallery,
                            endpoint,
                            request_method,
                            required_headers,
                            request_params) {
  base_url <- build_base_url(gallery, endpoint)
  normalized_request_params <-
    normalize_request_params(required_headers,
                             request_params)
  base_string <-
    build_base_string(request_method,
                      base_url,
                      normalized_request_params)
  signature <- sign_base_string(base_string)

  return(signature)
}
