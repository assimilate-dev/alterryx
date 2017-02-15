## Overview

`alterryx` provides functions to access each of the alteryx gallery api
endpoints listed in the [documentation](https://gallery.alteryx.com/api-docs/)

In order to use this package, you will need to have [a private gallery
API key and secret](https://community.alteryx.com/t5/Alteryx-Knowledge-Base/Private-Gallery-API-Key-and-Secret/ta-p/22009)

### Example

```
alteryx_api_key <- "<ALTERYX_API_KEY>"
alteryx_secret_key <- "ALTERYX_API_SECRET"

options(alteryx_api_key = alteryx_api_key)
options(alteryx_secret_key = alteryx_secret_key)

gallery <- "https://yourgallery.com/gallery"
```
Get all applications to which you are subscribed.
Alteryx Gallery subscriptions are better explained [here](https://community.alteryx.com/t5/tkb/articleprintpage/tkb-id/knowledgebase/article-id/782)
```
subscriptions <- get_apps(gallery)
```

Search for a specific application.
```
request_params <- list(
  search = "api"
)

subscriptions <- get_apps(gallery, request_params)
app <- subscriptions[[1]]
```
Get the questions for a given application
```
questions <- get_app_questions(gallery, app)
```

Queue an app to run with the given parameters (`request_body`)
```
#prepare values with which to run app
name_values <- list(
  name = "runtime",
  value = "3"
)
request_body <- build_request_body(name_values)

#queue a job for an application
job <- post_app_job(gallery, app, request_body)
```

`post_app_job` will return an alteryx_job object with status "Queued".
Get the current status of a job.
```
job <- get_job(gallery, job)
```

Once a job is "Completed" you can then request the outputs. Currently
the outputs are returns as a raw vector. I am working on handling this
output appropriately.
```
output <- get_job_output(gallery, job)

#example of handling the output
temp_output <- tempfile(fileext = ".xlsx")
writeBin(output[[1]], temp_output)
readxl::read_excel(temp_output)
```

## TO DO

* Handle binary data output from `get_job_output()`
