
#' Stockfish engine
#'
#' @description Don't forget to assign!
#'
#' @export
fish <- R6::R6Class(
  classname = "fish",

  # Public methods
  public = list(

    #' @field process Connection to `{processx}` process running engine
    process = NULL,

    #' @field output String vector with the output of the last run command
    output = NULL,

    #' @field log String vector with the all outputs from the engine
    log = NULL,

    #' @description Start Stockfish engine
    #'
    #' @param path Path to Stockfish executable (defaults to bundled version)
    initialize = function(path = NULL) {

      # Check for user-supplied executable
      exe <- if (is.null(path)) fish_find() else path.expand(path)

      # Start process
      self$process <- processx::process$new(exe, stdin = "|", stdout = "|", stderr = "|")

      # Record output
      self$process$poll_io(100)
      self$output <- self$process$read_output()
      self$log <- self$output

      # Give user some feedback
      return(self$process)
    },

    #' @description Send a command to be run on the engine.
    #'
    #' Every supported command is documented on the
    #' [UCI protocol](https://wbec-ridderkerk.nl/html/UCIProtocol.html) as
    #' publicized by Stefan-Meyer Kahlen. Please refrain from sending more than
    #' one command per call as the engine can get confused! Also note that
    #' commands automatically get a newline (`\n`) at the end, so there is no
    #' need to append that to the string itself.
    #'
    #' @param command A string with the command to run
    #' @param infinite Whether the command involves `go infinite` (will make
    #' function return instantly as output should only be collected when a
    #' `stop` command is issued)
    #'
    #' @return A string vector with the output of the command or `NULL`
    run = function(command, infinite = FALSE) {

      # Send command to engine
      self$process$write_input(paste0(command, "\n"))

      # If command is infinite, let it run without polling
      if (infinite) return(NULL)

      # Read from connection until process stops processing
      output <- c()
      while (TRUE) {

        # Poll IO and read output
        self$process$poll_io(500)
        tmp <- self$process$read_output()

        if (tmp == "") {
          break()
        }

        # Parse output
        output <- c(output, strsplit(tmp, "\n")[[1]])
      }

      # Update output field and the log
      self$output <- output
      self$log <- c(self$log, output)
      return(output)
    },

    #' @description Tell the engine to use the UCI.
    #'
    #' "Tell engine to use the uci (universal chess interface), this will be
    #' send once as a first command after program boot to tell the engine to
    #' switch to uci mode. After receiving the uci command the engine must
    #' identify itself with the 'id' command and sent the 'option' commands to
    #' tell the GUI which engine settings the engine supports if any. After that
    #' the engine should sent 'uciok' to acknowledge the uci mode. If no uciok
    #' is sent within a certain time period, the engine task will be killed by
    #' the GUI."
    uci = function() {
      invisible(self$run("uci"))
    },

    #' @description Ask if the engine is ready for more commands.
    #'
    #' "This is used to synchronize the engine with the GUI. When the GUI has
    #' sent a command or multiple commands that can take some time to complete,
    #' this command can be used to wait for the engine to be ready again or to
    #' ping the engine to find out if it is still alive. E.g. this should be
    #' sent after setting the path to the tablebases as this can take some time.
    #' This command is also required once before the engine is asked to do any
    #' search to wait for the engine to finish initializing. This command must
    #' always be answered with 'readyok' and can be sent also when the engine is
    #' calculating in which case the engine should also immediately answer with
    #' 'readyok' without stopping the search."
    #'
    #' @return Boolean indicating whether the output is exactly `"readyok"`
    isready = function() {
      return(self$run("isready")[1] == "readyok")
    },

    #' @description Change the internal parameters of the engine. All currently
    #' supported options (according to Stockfish's documentation) are listed
    #' below, but note that __those marked with an * require Stockfish 12__ to
    #' work):
    #'
    #' - `Threads`: the number of CPU threads used for searching a position. For
    #' best performance, set this equal to the number of CPU cores available.
    #' - `Hash`: the size of the hash table in MB. It is recommended to set Hash
    #' after setting Threads.
    #' - `Ponder`: let Stockfish ponder its next move while the opponent is
    #' thinking.
    #' - `MultiPV`: output the N best lines (principal variations, PVs) when
    #' searching. Leave at 1 for best performance.
    #' - `Use NNUE`*: toggle between the NNUE and classical evaluation functions.
    #' If set to "true", the network parameters must be available to load from
    #' file (see also EvalFile), if they are not embedded in the binary.
    #' - `EvalFile`*: the name of the file of the NNUE evaluation parameters.
    #' Depending on the GUI the filename might have to include the full path to
    #' the folder/directory that contains the file. Other locations, such as the
    #' directory that contains the binary and the working directory, are also
    #' searched.
    #' - `UCI_AnalyseMode`: an option handled by your GUI.
    #' - `UCI_Chess960`: an option handled by your GUI. If true, Stockfish will
    #' play Chess960.
    #' - `UCI_ShowWDL`*: tf enabled, show approximate WDL statistics as part of
    #' the engine output. These WDL numbers model expected game outcomes for a
    #' given evaluation and game ply for engine self-play at fishtest LTC
    #' conditions (60+0.6s per game).
    #' - `UCI_LimitStrength`*: enable weaker play aiming for an Elo rating as set
    #' by UCI_Elo. This option overrides Skill Level.
    #' - `UCI_Elo`*: if enabled by UCI_LimitStrength, aim for an engine strength
    #' of the given Elo. This Elo rating has been calibrated at a time control of
    #' 60s+0.6s and anchored to CCRL 40/4.
    #' - `Skill Level`: lower the Skill Level in order to make Stockfish play
    #' weaker (see also UCI_LimitStrength). Internally, MultiPV is enabled, and
    #' with a certain probability depending on the Skill Level a weaker move
    #' will be played.
    #' - `SyzygyPath`: path to the folders/directories storing the Syzygy
    #' tablebase files. Multiple directories are to be separated by ";" on
    #' Windows and by ":" on Unix-based operating systems. Do not use spaces
    #' around the ";" or ":". Example:
    #' `C:\tablebases\wdl345;C:\tablebases\wdl6;D:\tablebases\dtz345;D:\tablebases\dtz6`.
    #' It is recommended to store .rtbw files on an SSD. There is no loss in
    #' storing the .rtbz files on a regular HD. It is recommended to verify all
    #' md5 checksums of the downloaded tablebase files (`md5sum -c checksum.md5`)
    #' as corruption will lead to engine crashes.
    #' - `SyzygyProbeDepth`: minimum remaining search depth for which a position
    #' is probed. Set this option to a higher value to probe less aggressively
    #' if you experience too much slowdown (in terms of nps) due to TB probing.
    #' - `Syzygy50MoveRule`: disable to let fifty-move rule draws detected by
    #' Syzygy tablebase probes count as wins or losses. This is useful for ICCF
    #' correspondence games.
    #' - `SyzygyProbeLimit`: limit Syzygy tablebase probing to positions with at
    #' most this many pieces left (including kings and pawns).
    #' - `Contempt`: a positive value for contempt favors middle game positions
    #' and avoids draws, effective for the classical evaluation only.
    #' - `Analysis Contempt`: by default, contempt is set to prefer the side to
    #' move. Set this option to "White" or "Black" to analyse with contempt for
    #' that side, or "Off" to disable contempt.
    #' - `Move Overhead`: assume a time delay of x ms due to network and GUI
    #' overheads. This is useful to avoid losses on time in those cases.
    #' - `Slow Mover`: lower values will make Stockfish take less time in games,
    #' higher values will make it think longer.
    #' - `nodestime`: tells the engine to use nodes searched instead of wall time
    #' to account for elapsed time. Useful for engine testing.
    #' - `Clear Hash`: clear the hash table.
    #' - `Debug Log File`: write all communication to and from the engine into a
    #' text file.
    #'
    #' "This is sent to the engine when the user wants to change the internal
    #' parameters of the engine. For the 'button' type no value is needed. One
    #' string will be sent for each parameter and this will only be sent when
    #' the engine is waiting. The name of the option in  should not be case
    #' sensitive and can inludes spaces like also the value. The substrings
    #' 'value' and 'name' should be avoided in  and  to allow unambiguous
    #' parsing, for example do not use = 'draw value'. Here are some strings
    #' for the example below:
    #'
    #' - `setoption name Nullmove value true\n`
    #' - `setoption name Selectivity value 3\n`
    #' - `setoption name Style value Risky\n`
    #' - `setoption name Clear Hash\n`
    #' - `setoption name NalimovPath value c:\chess\tb\4;c:\chess\tb\5\n`"
    #'
    #' @param name Name of the option
    #' @param value Value to set (or `NULL` option doesn't neet a value)
    setoption = function(name, value = NULL) {

      # Build command
      command <- paste("setoption name", name)
      if (!is.null(value)) {
        command <- paste(command, "value", value)
      }

      invisible(self$run(command))
    },

    #' @description Tell the engine that the next search will be from a
    #' different game.
    #'
    #' "This is sent to the engine when the next search (started with 'position'
    #' and 'go') will be from a different game. This can be a new game the
    #' engine should play or a new game it should analyse but also the next
    #' position from a testsuite with positions only. If the GUI hasn't sent a
    #' 'ucinewgame' before the first 'position' command, the engine shouldn't
    #' expect any further ucinewgame commands as the GUI is probably not
    #' supporting the ucinewgame command. So the engine should not rely on this
    #' command even though all new GUIs should support it. As the engine's
    #' reaction to 'ucinewgame' can take some time the GUI should always send
    #' 'isready' after ucinewgame to wait for the engine to finish its
    #' operation."
    ucinewgame = function() {
      invisible(self$run("ucinewgame\nisready"))
    },

    #' @description Set up the position on the internal board.
    #'
    #' "Set up the position described in fenstring on the internal board and play
    #' the moves on the internal chess board. if the game was played  from the
    #' start position the string 'startpos' will be sent. Note: no 'new' command
    #' is needed. However, if this position is from a different game than the
    #' last position sent to the engine, the GUI should have sent a 'ucinewgame'
    #' inbetween."
    #'
    #' @param position String with position (either a FEN or a sequence of moves
    #' separated by spaces)
    #' @param type Either `"fen"` or `"startpos"`, respectively
    position = function(position = NULL, type = c("fen", "startpos")) {
      type <- match.arg(type)
      invisible(self$run(paste("position", type, position)))
    },

    #' @description Start calculating on the current position.
    #'
    #' "Start calculating on the current position set up with the 'position'
    #' command. There are a number of commands that can follow this command, all
    #' will be sent in the same string. If one command is not send its value
    #' should be interpreted as it would not influence the search.
    #'
    #' - `searchmoves`: restrict search to this moves only. Example: after
    #' 'position startpos' and 'go infinite searchmoves e2e4 d2d4' the engine
    #' should only search the two moves e2e4 and d2d4 in the initial position.
    #' - `ponder`: start searching in pondering mode. Do not exit the search in
    #' ponder mode, even if it's mate! This means that the last move sent in the
    #' position string is the ponder move. The engine can do what it wants to
    #' do, but after a 'ponderhit' command it should execute the suggested move
    #' to ponder on. This means that the ponder move sent by the GUI can be
    #' interpreted as a recommendation about which move to ponder. However, if
    #' the engine decides to ponder on a different move, it should not display
    #' any mainlines as they are likely to be misinterpreted by the GUI because
    #' the GUI expects the engine to ponder on the suggested move.
    #' - `wtime`: white has x msec left on the clock.
    #' - `btime`: black has x msec left on the clock.
    #' - `winc`: white increment per move in mseconds if x > 0.
    #' - `binc`: black increment per move in mseconds if x > 0.
    #' - `movestogo`: there are x moves to the next time control, this will only
    #' be sent if x > 0, if you don't get this and get the wtime and btime it's
    #' sudden death.
    #' - `depth`: search x plies only.
    #' - `nodes`: search x nodes only.
    #' - `mate`: search for a mate in x moves.
    #' - `movetime`: search exactly x mseconds.
    #' - `infinite`: search until the 'stop' command. Do not exit the search
    #' without being told so in this mode!"
    #'
    #' @param searchmoves A string with the only moves (separated by spaces)
    #' that should be searched
    #' @param ponder Pondering move (see documentation for more information)
    #' @param wtime Time (in ms) white has left on the clock (if `movestogo` is
    #' not set, it's sudden death)
    #' @param btime Time (in ms) black has left on the clock (if `movestogo` is
    #' not set, it's sudden death)
    #' @param winc White increment (in ms) per move if `wtime > 0`
    #' @param binc Black increment (in ms) per move if `btime > 0`
    #' @param movestogo Number of moves to the next time control
    #' @param depth Maximum number of plies to search
    #' @param nodes Maximum number of nodes to search
    #' @param mate Search for a mate in this number of moves
    #' @param movetime Time (in ms) allowed for searching
    #' @param infinite Whether to search until a `stop` command is issued (makes
    #' function return instantly without any output)
    #'
    #' @return A string with the result of search or `NULL` if `infinite == TRUE`
    go = function(searchmoves = NULL, ponder = NULL, wtime = NULL, btime = NULL,
                  winc = NULL, binc = NULL, movestogo = NULL, depth = NULL,
                  nodes = NULL, mate = NULL, movetime = NULL, infinite = FALSE) {

      # List all arguments
      args <- list(
        "searchmoves" = searchmoves,
        "ponder" =  ponder,
        "wtime" =  wtime,
        "btime" =  btime,
        "winc" =  winc,
        "binc" =  binc,
        "movestogo" = movestogo,
        "depth" =  depth,
        "nodes" =  nodes,
        "mate" =  mate,
        "movetime" = movetime
      )

      # Paste all arguments
      command <- ""
      for (i in seq_along(args)) {
        if (!is.null(args[[i]])) {
          command <- paste(command, names(args)[i], args[[i]])
        }
      }

      # Choose either 'go' or 'go infinite'
      if (infinite) {
        command <- paste0("go infinite", command)
      } else {
        command <- paste0("go", command)
      }

      # Run command and read output
      return(utils::tail(self$run(command, infinite), 1))
    },

    #' @description Stop calculating as soon as possible
    #'
    #' "Stop calculating as soon as possible, don't forget the 'bestmove' and
    #' possibly the 'ponder' token when finishing the search"
    #'
    #' @return A string with the result of search or `NULL` if there was no
    #' search underway
    stop = function() {
      return(utils::tail(self$run("stop"), 1))
    },

    #' @description Tell the engine that the user has played the expected move.
    #'
    #' "The user has played the expected move. This will be sent if the engine
    #' was told to ponder on the same move the user has played. The engine
    #' should continue searching but switch from pondering to normal search."
    ponderhit = function() {
      invisible(self$run("ponderhit"))
    },

    #' @description Kill the engine
    #'
    #' "Quit the program as soon as possible"
    quit = function() {
      self$run("quit")
      invisible(TRUE)
    },

    #' @description Print information about engine process
    #'
    #' @param ... Arguments passed on to `print()`
    print = function(...) {
      print(self$process, ...)
    }
  )
)

#' Find bundled Stockfish executable
#'
#' @export
fish_find <- function() {

  # Find all paths where bin can be (necessary when using load_all())
  paths <- paste0(.libPaths(), "/stockfish/bin")

  # Select the first valid path and handle Windows architectures
  path <- paths[dir.exists(paths)][1]
  path <- paste0(path, "/", .Platform$r_arch)

  # Find executable and tidy path
  file <- list.files(path, full.names = TRUE, pattern = "stockfish($|.exe)")
  file <- gsub("//", "/", file)

  return(file)
}
