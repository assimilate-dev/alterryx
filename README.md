## Overview

`alterryx` provides functions to access each of the alteryx gallery api
endpoints listed in the [documentation](https://gallery.alteryx.com/api-docs/)

In order to use this package, you will need to have [a private gallery
API key and secret](https://community.alteryx.com/t5/Alteryx-Knowledge-Base/Private-Gallery-API-Key-and-Secret/ta-p/22009)

### Example

```
alteryx_api_key <- "<ALTERYX_API_KEY>"
alteryx_secret_key <- "ALTERYX_API_SECRET"
gallery <- "https://yourgallery.com/gallery"

options(alteryx_api_key = alteryx_api_key)
options(alteryx_secret_key = alteryx_secret_key)
options(alteryx_gallery = gallery)
```
Get all applications to which you are subscribed.
Alteryx Gallery subscriptions are better explained [here](https://community.alteryx.com/t5/tkb/articleprintpage/tkb-id/knowledgebase/article-id/782)
```
subscriptions <- get_apps()
```

Search for a specific application.
```
request_params <- list(
  search = "api"
)

subscriptions <- get_app(request_params)
app <- subscriptions[[1]]
```
Get the questions for a given application
```
questions <- get_app_questions(app)
```

Queue an app to run with the given parameters (`answers`)
```
#prepare values with which to run app
name_values <- list(
  name = "runtime",
  value = "3"
)
answers <- build_answers(name_values)

#queue a job for an application
job <- queue_job(app, answers)
```

`queue_job` will return an alteryx_job object with status "Queued".
Get the current status of a job.
```
job <- get_job(job)
```

Once a job is "Completed" you can then request the outputs and download them
to your local machine.
```
output <- job_output(job)

download_job_output(job)
```

## TO DO

* S3 Documentation
