#' Get Applications (Admin)
#'
#' Just like \code{get_app}, except when you're using admin keys. If your not
#' doing migration or management, you probably don't need this function.
#'
#' This requires a separate function because more information is returned for
#' a resource by the admin API than the generic API.
#'
#' @inheritParams get_app
#'
#' @export
get_app_admin <- function(request_params = list(),
                          gallery = get_gallery()) {
  endpoint <- "/api/admin/v1/workflows/"

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params)

  if(length(content)) {
    content <- lapply(content, as.alteryx_app_admin)
  } else {
    content <- list()
  }

  return(content)
}

#' Get Applications (Admin)
#'
#' Just like \code{download_app}, except when you're using admin keys. If your
#' not doing migration or management, you probably don't need this function.
#'
#' This requires a separate function because more information is returned for
#' a resource by the admin API than the generic API.
#'
#' @return Raw binary for the resource .yxwz
#'
#' @inheritParams get_app_questions
#'
#' @export
download_app_admin <- function(app,
                               gallery = get_gallery()) {
  class_check <- check_class(app, "app_admin")

  endpoint <- "/api/admin/v1/{appId}/package/"
  app_id <- app$id
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  request_params <- list()

  content <- submit_get_request(gallery,
                                endpoint,
                                request_params,
                                as = "raw",
                                remove_bom = FALSE,
                                parse_JSON = FALSE)

  return(content)
}
