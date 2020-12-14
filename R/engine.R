
#' Find installed Stockfish
#'
#' @export
fish_find <- function() {

  .libPaths() %>%
    paste0("/stockfish/bin") %>%
    magrittr::extract(dir.exists(.)) %>%
    magrittr::extract(1) %>%
    paste0("/", .Platform$r_arch) %>%
    list.files(full.names = TRUE, pattern = "stockfish($|.exe)") %>%
    gsub("//", "/", .)
}

#' Start Stockfish engine
#'
#' @param path Path to Stockfish executable (defaults to bundled executable)
#'
#' @export
fish_start <- function(path = NULL) {

  # Check for user-supplied executable
  exe <- if (is.null(path)) fish_find() else path.expand(path)

  # Start process
  engine <- processx::process$new(exe, stdin = "|", stdout = "|", stderr = "|")
  engine
}

#' Stop Stockfish running process
#'
#' @param engine A Stockfish engine
#'
#' @export
fish_stop <- function(engine) {

  engine$kill()
  invisible(TRUE)
}
