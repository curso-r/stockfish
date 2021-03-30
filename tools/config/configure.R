# Prepare your package for installation here.
# Use 'define()' to define configuration variables.
# Use 'configure_file()' to substitute configuration values.

configure_file("src/Makevars.in")

is_solaris <- function() {
  grepl('SunOS', Sys.info()['sysname'])
}

if (is_solaris()) {
  define(SRC = "dummy.cpp")
} else {
  define(SRC = "benchmark.cpp bitbase.cpp bitboard.cpp endgame.cpp evaluate.cpp main.cpp material.cpp misc.cpp movegen.cpp movepick.cpp pawns.cpp position.cpp psqt.cpp search.cpp tbprobe.cpp thread.cpp timeman.cpp tt.cpp uci.cpp ucioption.cpp")
}

