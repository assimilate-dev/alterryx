# alteryx 0.6.0

* `publish()` now saves files in the staging directory as .yxzp instead of
.yx(wz/mc/md)

# alterryx 0.5.0

* Add support for new migration endpoints introduced in 2018.4

* Startup message will now indicate level of support

* Limited support for admin API functions: `get_app_admin` and
`download_app_admin`

# alterryx 0.4.0

* Forward slash at the end of Gallery URL will no longer produce an error

* Updated client to reflect changes in Alteryx Gallery API with 2018.3 release
    - Queue jobs with priority

# alterryx 0.3.1

* API functions will no longer produce an invalid signature message when using
special characters (such as spaces) in parameter string

* Updated client to reflect changes in Alteryx Gallery API with 2018.1 release

# alterryx 0.3.0

* Updated version dependency for jsonlite as older versions of the package do
not contain the `write_json` function

* Added `empty_answer` to streamline the process of queueing apps with no
questions

* Improved `print` formatting for `alteryx_job` and `altery_app`

* `get_info` will now print less information by default to improve readability.
Added the binary parameter `full_info` to print all info from the API.

* `queue_job` can now "track" a job. If `track_job = TRUE`, the function will
not return a value until the job has finished running on the Alteryx Gallery
