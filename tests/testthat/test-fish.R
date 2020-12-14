test_that("engine works", {

  # Find executable
  expect_type(fish_find(), "character")

  # Start engine
  engine <- fish$new()
  expect_true(engine$process$is_alive())
  expect_gt(engine$process$get_pid(), 0)
  expect_equal(engine$output[2], "readyok")

  # Test commands
  expect_invisible(engine$cmd("isready"))
  expect_invisible(engine$uci())
  expect_equal(engine$uci()[25], "uciok")

  # Stop engine
  engine$quit()
  expect_false(engine$process$is_alive())
  expect_error(engine$process$get_status())

  # Restart engine
  engine <- fish$new()

  # Test more commands
  expect_invisible(engine$position(moves = "e2e4"))
  expect_equal(engine$cmd("isready"), "readyok")
  expect_invisible(engine$ucinewgame())
  expect_length(engine$position(moves = "e2e4"), 0)
  expect_length(engine$go(depth = 10), 3)
  expect_true(engine$isready())
  expect_length(engine$ucinewgame(), 0)
  expect_length(engine$go(depth = 10, infinite = TRUE), 3)
  expect_invisible(engine$stop())
})
