test_that("engine works", {

  # Find executable
  expect_type(fish_find(), "character")

  # Start engine
  engine <- fish$new()
  expect_true(engine$process$is_alive())
  expect_gt(engine$process$get_pid(), 0)
  expect_true(grepl("Stockfish 11", engine$output))

  # Test commands
  expect_true(engine$isready())
  expect_equal(engine$uci()[25], "uciok")

  # Stop engine
  engine$quit()
  expect_false(engine$process$is_alive())
  expect_error(engine$process$get_status())

  # Restart engine
  engine <- fish$new()

  # Test more commands
  expect_output(print(engine), "PROCESS")
  tmp <- engine$position("e2e4", "startpos")
  expect_true(is.null(tmp) || grepl("Stockfish 11", tmp))
  expect_equal(engine$ucinewgame(), "readyok")
  expect_null(engine$setoption("Clear Hash"))
  expect_length(engine$go(depth = 10, movetime = 1000), 1)
  expect_true(engine$isready())
  expect_equal(engine$ucinewgame(), "readyok")
  expect_null(engine$go(infinite = TRUE))
  expect_length(engine$stop(), 1)

  # Test members
  expect_type(engine$process, "environment")
  expect_true(grepl("bestmove", utils::tail(engine$output, 1)))
  expect_gt(length(engine$log), 10)

  # Stop and quit
  expect_invisible(engine$quit())
})
