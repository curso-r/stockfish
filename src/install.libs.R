exec <- "stockfish"
if(WINDOWS) exec <- paste0(exec, ".exe")
if ( any(file.exists(exec)) ) {
  dest <- file.path(rappdirs::user_data_dir("r-stockfish"), "bin")
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  file.copy(exec, dest, overwrite = TRUE)
}
