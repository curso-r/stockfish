library(testthat)
library(stockfish)

is_solaris <- function() {
  grepl('SunOS', Sys.info()['sysname'])
}

is_m1 <- function() {
  !R.version$arch == "x86_64"
}

if (!is_solaris() && !is_m1())
  test_check("stockfish")
