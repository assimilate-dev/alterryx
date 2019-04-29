.onAttach <- function(libname, pkgname) {
  message <- paste("This version of alterryx was built and tested for",
                   "Alteryx Server 2019.1. Support for earlier versions is",
                   "not guaranteed")
  packageStartupMessage(message)
}
