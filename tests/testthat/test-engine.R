test_that("engine can be created and stopped", {

  # Start engine
  fish <- fish_start()
  expect_true(fish$is_alive())
  expect_gt(fish$get_pid(), 0)

  # Stop engine
  fish_stop(fish)
  expect_false(fish$is_alive())
  expect_error(fish$get_status())
})
