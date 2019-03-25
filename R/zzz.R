.onAttach <- function(libname, pkgname) {
  packageStartupMessage("This version of alterryx was built and tested
                         for Alteryx Server 2018.4. Support for earlier
                         versions is not guaranteed.")
}
