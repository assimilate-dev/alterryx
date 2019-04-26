#' Migrate Workflows
#'
#' @description The migration endpoints require access to the Gallery admin
#' API. Users cannot authorize using non-admin keys.
#'
#' Migrating workflows is a four-step process:
#'
#' \enumerate{
#'   \item Find all Gallery resources marked as "Ready to Migrate"
#'   \item Download the resources from the source environment
#'   \item Publish the resources to the target environment
#'   \item Toggle "Ready to Migrate" flag
#' }
#'
#' The functions \code{get_migratable}, \code{publish}, and
#' \code{toggle_migratable} perform the above tasks individually:
#'
#' \itemize{
#'   \item \code{get_migratable}: Returns a \code{list} of resources marked as
#'   ready for migration in Gallery
#'   \item \code{publish}: Downloads and publishes resources
#'   \item \code{toggle_migratable}: Toggles "Ready to Migrate" flag
#' }
#'
#' The function \code{migrate} is provided as a wrapper to automate migration
#' from end-to-end.
#'
#' @section Additional Information:
#' Remember to set your API key, secret, and Gallery location for the target
#' environment.
#'
#' It is possible for deleted resources to show as marked for migration. In
#' this situation, you will see a message that the resource was "(Skipped due
#' to a problem)."
#'
#' It is possible to migrate from and to the same environment.
#'
#' @return NULL value. Use \code{verbose = TRUE} to see migration status.
#'
#' @param subscription A \code{list} of subscriptions ids to filter migratable
#' results by private studio
#' @param gallery URL for your Alteryx Gallery
#' @param verbose Print information related to migration status
#' @param app A single \code{alteryx_app} returned from \code{get_app}
#' @param migration_directory A directory for storing downloaded resources.
#' Defaults to a random temporary directory.
#' @param form A \code{list} that contains metadata for the published resource
#' in the target environment. If NULL, the defaults will be assumed from the
#' source environment. A \code{list} that contains \itemize{
#'   \item name
#'   \item owner
#'   \item validate
#'   \item isPublic
#'   \item sourceId
#'   \item workerTag
#'   \item canDownload
#' }
#' @param target_alteryx_api_key Admin API key for target environment
#' @param target_alteryx_secret_key Admin API secret key for target environment
#' @param target_gallery URL for your target Alteryx Gallery
#'
#' @aliases get_migratable publish toggle_migratable
#'
#' @examples
#' \dontrun{
#' # to run manually
#' app <- get_migratable()[[1]]
#' form <- list(
#'   name = "app_name.yxwz",
#'   owner = "new_owner_email@domain.com",
#'   validate = "false",
#'   isPublic = "false",
#'   sourceId = "ABC123",
#'   workerTag = "",
#'   canDownload = "false"
#' )
#'
#' publish(
#'   app,
#'   migration_directory = "c:/aspot/tostage/files"
#'   form = form
#' )
#'
#' toggle_migratable(app)
#'
#' # automated
#' migrate(
#'   form = form,
#'   migration_directory = "c:/aspot/tostage/files"
#' )
#'
#' }
#'
#' @name migrate
#' @export
migrate <- function(migration_directory = NULL,
                    subscription = list(),
                    form = NULL,
                    gallery = get_gallery(),
                    target_alteryx_api_key =
                      getOption('target_alteryx_api_key'),
                    target_alteryx_secret_key =
                      getOption('target_alteryx_secret_key'),
                    target_gallery =
                      getOption('target_alteryx_gallery'),
                    verbose = TRUE) {

  if(verbose)
    cat_paste(
      "\nBeginning Migration...",
      "\n"
    )

  migratable <- get_migratable(subscription,
                               gallery,
                               verbose)

  lapply(
    migratable,
    function(x, x_form) {

      if(!is.null(x_form)) {
        form$name <- x$fileName
        form$sourceId <- x$id
      }

      publish(x,
              migration_directory,
              form,
              target_alteryx_api_key,
              target_alteryx_secret_key,
              target_gallery,
              verbose)
    },
    x_form = form
  )

  if(verbose)
    cat_paste(
      "Toggling Migrate Flag...",
      "\n"
    )

  if(verbose)
    cat_paste(
      "Done",
      "\n"
    )

  lapply(
    migratable,
    function(x) {
      toggle_migratable(x,
                        gallery)
    }
  )

  return(invisible(NULL))

}

#' @rdname migrate
#'
#' @export
get_migratable <- function(subscription = list(),
                           gallery = get_gallery(),
                           verbose = TRUE) {
  endpoint <- "/api/admin/v1/workflows/migratable/"

  if(verbose)
    cat_paste(
      "\nSearching for resources marked for migration...",
      "\n"
    )

  content <- submit_get_request(gallery,
                                endpoint,
                                subscription)

  if(verbose)
    cat_paste(
      toString(length(content)),
      "resources found...",
      "\n\n"
    )

  if(length(content)) {

    ids <- lapply(
      seq_along(content),
      function(x, i) {
        list(
          search = x[[i]]$id
        )
      },
      x = content
    )

    resources <- lapply(
      ids,
      function(x) {
        app <- get_app_admin(request_params = x)
        if(length(app)) {
          resource <- app[[1]]
          if(verbose)
            cat_paste(
              "  ",
              resource$fileName,
              "\n"
            )
        } else {
          if(verbose)
            cat_paste(
              "  ",
              x$search,
              "(Skipped due to problem)",
              "\n"
            )
          resource <- NULL
        }

        return(resource)
      }
    )

    resources <- resources[!sapply(resources, is.null)]

  } else {
    resources <- list()
  }

  return(invisible(resources))
}

#' @rdname migrate
#'
#' @export
publish <- function(app,
                    migration_directory = NULL,
                    form = NULL,
                    target_alteryx_api_key =
                      getOption('target_alteryx_api_key'),
                    target_alteryx_secret_key =
                      getOption('target_alteryx_secret_key'),
                    target_gallery =
                      getOption('target_alteryx_gallery'),
                    verbose = TRUE) {

  class_check <- check_class(app, "app_admin")
  key_check <- check_keys(type = "target")

  cat_paste("\n")

  if(verbose)
    cat_paste(
      app$fileName,
      "\n---------------",
      "\n"
    )

  if(is.null(migration_directory) & verbose) {
    migration_directory <- tempdir()
    cat_paste(
      "  No migration directory provided. Saving files to",
      migration_directory,
      "\n"
    )
  }

  endpoint <- "/api/admin/v1/workflows/"
  request_params <- list()

  if(is.null(form)) {
    form <- get_migration_form(app)
    if(verbose)
      cat_paste(
        "  No form provided. Assuming defaults from source environment.",
        "\n"
      )
  }

  file <- file.path(migration_directory, app$fileName)

  if(verbose)
    cat_paste(
      "  Downloading workflow...",
      "\n"
    )

  app_bin <- download_app_admin(app)

  if(verbose)
    cat_paste(
      "  Saving workflow...",
      "\n"
    )

  writeBin(app_bin, file)

  if(verbose)
    cat_paste(
      "  Publishing workflow to target environment...",
      "\n"
    )

  form <- append(list(file = httr::upload_file(file)), form)
  content <- submit_post_request(target_gallery,
                                 endpoint,
                                 request_params,
                                 request_body = form,
                                 encode = "multipart",
                                 alteryx_api_key =
                                   target_alteryx_api_key,
                                 alteryx_secret_key =
                                   target_alteryx_secret_key)

  if(verbose)
    cat_paste(
      "  Done. Publish in target environment as",
      content,
      "\n\n"
    )

  return(invisible(NULL))

}

#' @rdname migrate
#'
#' @export
toggle_migratable <- function(app,
                              gallery = get_gallery()) {
  class_check <- check_class(app, "app_admin")

  endpoint <- "/api/admin/v1/workflows/migratable/{appId}/"
  app_id <- app$id
  endpoint <- gsub("\\{appId\\}", app_id, endpoint)

  request_params <- list()

  content <- submit_put_request(gallery,
                                endpoint,
                                request_params)
}
