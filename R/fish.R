
#' Stockfish engine
#'
#' @description This class wraps `bigchess`'s functions for handling
#' UCI-compatible engines. Instead of a functional workflow, this OOP approach
#' allows for more persistent interations with the engine.
#'
#' @export
fish <- R6::R6Class(
  classname = "fish",

  public = list(

    #' @field process Connection to `{processx}` process running engine
    process = NULL,

    #' @field output String vector with the latest output of the engine
    output = NULL,

    #' @description Start Stockfish engine
    #' @param path Path to Stockfish executable (defaults to bundled version)
    initialize = function(path = NULL) {

      # Check for user-supplied executable
      exe <- if (is.null(path)) fish_find() else path.expand(path)

      # Start process
      engine <- bigchess::uci_engine(exe)

      # Assign public members
      self$process <- engine$pipe
      self$output <- engine$temp

      # Assign private members
      private$engine <- engine
      private$log <- engine$temp
    },

    #' @description Send command to Stockfish engine
    #' @param command String with UCI command
    cmd = function(command) {
      private$engine <- bigchess::uci_cmd(private$engine, command)
      invisible(private$read())
    },

    # #' @description Set debug on or off
    # #' @param state Either `"on"` or `"off"`
    # debug = function(state = c("on", "off")) {
    #   state <- match.arg(state)
    #   private$engine <- bigchess::uci_debug(private$engine, state == "on")
    #   invisible(private$read())
    # },

    #' @description Start calculating on the current position
    #' @param wtime Time (in msec) white has left on the clock
    #' @param btime Time (in msec) black has left on the clock
    #' @param winc White increment (in msec) per move if `wtime > 0`
    #' @param binc Black increment (in msec) per move if `btime > 0`
    #' @param depth Maximum number of plies to search
    #' @param infinite Whether to search until `stop()` command
    #' @param time Timeout (in seconds) for infinite computation
    go = function(wtime = NULL, btime = NULL, winc = NULL, binc = NULL,
                  depth = NULL, infinite = FALSE, time = 1) {

      # Run command and read output
      private$engine <- bigchess::uci_go(
        private$engine, depth, infinite, time, wtime, btime, winc, binc
      )
      private$read()

      # Return parsed output
      list(
        bestmove = private$parse("bestmove"),
        score = private$parse("score"),
        bestline = private$parse("bestline")
      )
    },

    #' @description Wait for the engine to be ready again
    isready = function() {
      private$engine <- bigchess::uci_isready(private$engine)
      return(private$read() == "readyok")
    },

    # #' @description
    # ponderhit = function() {
    #   private$engine <- bigchess::uci_ponderhit(private$engine)
    #   invisible(private$read())
    # },

    #' @description Set up the position on the internal board
    #' @param moves String with LAN moves
    #' @param startpos Whether starting from start position
    #' @param fen String with FEN board
    position = function(moves = NULL, startpos = TRUE, fen = NULL) {
      private$engine <- bigchess::uci_position(private$engine, moves, startpos, fen)
      invisible(private$read())
    },

    #' @description Kill Stockfish engine
    quit = function() {
      bigchess::uci_quit(private$engine)
      invisible(TRUE)
    },

    # #' @description Register username and/or a code
    # #' @param later Whether to register later
    # #' @param name String with name
    # #' @param code String with code
    # register = function(later = TRUE, name = NULL, code = NULL) {
    #   private$engine <- bigchess::uci_register(private$engine, later, name, code)
    #   invisible(private$read())
    # },

    # #' @description Change the internal parameters of the engine
    # #' @param name Name of the option
    # #' @param value Value to set
    # setoption = function(name, value) {
    #   private$engine <- bigchess::uci_setoption(private$engine, name, value)
    #   invisible(private$read())
    # },

    #' @description Stop calculating as soon as possible
    stop = function() {
      private$engine <- bigchess::uci_stop(private$engine)
      invisible(private$read())
    },

    #' @description Tell engine to use the UCI
    uci = function() {
      private$engine <- bigchess::uci_uci(private$engine)
      invisible(private$read())
    },

    #' @description Tell the next search will be from a different game
    ucinewgame = function() {
      private$engine <- bigchess::uci_ucinewgame(private$engine)
      invisible(private$read())
    }
  ),

  private = list(

    # @field engine Internal `engine` object for `{bigchess}`
    engine = NULL,

    # @field log Log with the whole output from engine
    log = NULL,

    # @description Read output of the last move
    read = function() {
      private$engine <- bigchess::uci_read(private$engine)

      # Update log and last output
      self$output <- private$engine$temp[-seq_along(private$log)]
      private$log <- private$engine$temp

      return(self$output)
    },

    # @description Parse output of last command
    # @param filter What to return (one of `"bestmove"`, `"score"`, `"bestline"`)
    parse = function(filter = c("bestmove", "score", "bestline")) {
      filter <- match.arg(filter)
      bigchess::uci_parse(private$log, filter)
    }
  )
)

#' Find bundled Stockfish
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
