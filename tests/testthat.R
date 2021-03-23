library(testthat)
library(stockfish)

is_solaris <- function() {
  grepl('SunOS',Sys.info()['sysname'])
}

if (!is_solaris())
  test_check("stockfish")
