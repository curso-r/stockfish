library(testthat)
library(stockfish)

# Detect Solaris
is_solaris <- function() {
  grepl("SunOS", Sys.info()["sysname"])
}

# Solaris users will have to install 'Stockfish 11' manually depending on their
# compiler (e.g. the bundled version was working on R-hub, but not on CRAN).
# Since the tests are supposed to guarantee that the bundled version installed
# correctly, they are skipped.
if (!is_solaris()) {
  test_check("stockfish")
}
