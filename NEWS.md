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

# alterryx 0.2.0.9000

* Added a `NEWS.md` file to track changes to the package.



