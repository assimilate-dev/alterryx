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

#get all applications to which you are subscribed
subscriptions <- get_subscriptions(gallery)

#get the app questions for an application
app_id <- subscriptions[[1]]$id
questions <- get_app_questions(gallery, app_id)

#prepare values with which to run app
name_values <- questions[[1]][c("name", "value")]
name_values$value <- "2"
request_body <- build_request_body(name_values)

#queue a job for an application
new_job <- post_app_job(gallery, app_id, request_body)

#get the job status
new_job_id <- new_job$id
new_job_output_id <- get_job(gallery, new_job_id)$outputs[[1]]$id

#get the job output
get_job_output(gallery, new_job_id, new_job_output_id)
```

## TO DO

* Address UTF-8 warnings when accessing an endpoint
* Handle binary data output from `get_job_output()`
