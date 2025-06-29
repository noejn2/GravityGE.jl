test_that("Checks welfare remove according to theoretical expectations", {

  # --------------------------------------------------------------------------------------------------------------- #
  #  Variable  |  No change     | More bitrade costs |  Less bitrade costs | More productivity | Less productivity  #
  # -----------|----------------|--------------------|---------------------|-------------------|------------------- #
  #  Welfare   |  No change     | Decrease           |  Increase           | Increase          | Decrease           #
  # --------------------------------------------------------------------------------------------------------------- #

  flows <- expand.grid(LETTERS, LETTERS)
  flows$flow <- 1
  names(flows)[1:2] <- c("orig", "dest")

  # No change
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = NULL,
    multiplicative = F
  )
  expect_equal(out$new_welfare$welfare , rep(1, length(letters)))

  # No change
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = NULL,
    multiplicative = F
  )
  expect_equal(out$new_welfare$welfare , rep(1, length(letters)))

  # More bitrade costs
  flows$bitrade_costs <- -4*log(1.5) # Doubling the bitrade costs
  flows$bitrade_costs[flows$orig == flows$dest] <- 0
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = "bitrade_costs",
    a_hat_name = NULL,
    multiplicative = F
  )
  expect(all(out$new_welfare$welfare <= rep(1, length(letters))), failure_message = "Welfare should decrease when bitrade costs increase.")

  # Less bitrade costs
  flows$bitrade_costs <- -4*log(0.5) # Halving the bitrade costs
  flows$bitrade_costs[flows$orig == flows$dest] <- 0
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = "bitrade_costs",
    a_hat_name = NULL,
    multiplicative = F
  )

  expect(all(out$new_welfare$welfare >= rep(1, length(letters))), failure_message = "Welfare should increase when bitrade costs decrease.")

  # More productivity
  flows$prod <- 2 # Doubling the productivity
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = "prod",
    multiplicative = F
  )

  expect(all(out$new_welfare$welfare >= rep(1, length(letters))), failure_message = "Welfare should increase when productivity increases.")

  # Less productivity
  flows$prod <- 0.5 # Halving the productivity
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = "prod",
    multiplicative = F
  )

  expect(all(out$new_welfare$welfare <= rep(1, length(letters))), failure_message = "Welfare should decrease when productivity decreases.")

  # No change
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = NULL,
    multiplicative = T
  )
  expect_equal(out$new_welfare$welfare , rep(1, length(letters)))

  # No change
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = NULL,
    multiplicative = T
  )
  expect_equal(out$new_welfare$welfare , rep(1, length(letters)))

  # More bitrade costs
  flows$bitrade_costs <- -4*log(1.5) # Doubling the bitrade costs
  flows$bitrade_costs[flows$orig == flows$dest] <- 0
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = "bitrade_costs",
    a_hat_name = NULL,
    multiplicative = T
  )
  expect(all(out$new_welfare$welfare <= rep(1, length(letters))), failure_message = "Welfare should decrease when bitrade costs increase.")

  # Less bitrade costs
  flows$bitrade_costs <- -4*log(0.5) # Halving the bitrade costs
  flows$bitrade_costs[flows$orig == flows$dest] <- 0
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = "bitrade_costs",
    a_hat_name = NULL,
    multiplicative = T
  )

  expect(all(out$new_welfare$welfare >= rep(1, length(letters))), failure_message = "Welfare should increase when bitrade costs decrease.")

  # More productivity
  flows$prod <- 2 # Doubling the productivity
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = "prod",
    multiplicative = T
  )

  expect(all(out$new_welfare$welfare >= rep(1, length(letters))), failure_message = "Welfare should increase when productivity increases.")

  # Less productivity
  flows$prod <- 0.5 # Halving the productivity
  out <- gravityGE::gravityGE(
    trade_data = flows,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = "prod",
    multiplicative = T
  )

  expect(all(out$new_welfare$welfare <= rep(1, length(letters))), failure_message = "Welfare should decrease when productivity decreases.")






})
