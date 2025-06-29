#' Solves one sector Armington-CES gravity model with general equilibrium
#'
#' @param trade_data A data frame that contains 'orig', 'dest', and 'flow' named columns, with additional variables as described below.
#' @param theta Trade elasticity parameter (default = 4).
#' @param beta_hat_name A character name in trade_data for the beta_hat variable. If NULL, a matrix of ones is used. Domestic trade ('orig' == 'dest') must have a value of 0.
#' @param a_hat_name A character name in trade_data for the a_hat variable. If NULL, a matrix of ones is used. All values across 'orig' in a_hat must be the same.
#' @param multiplicative Logical. If TRUE, the model is multiplicative. If FALSE, the model is additive. Default = FALSE. Additive is recommended when trade data is unbalanced.
#'
#' @return A list containing two data frames. A dyadic ('orig' and 'dest') data frame with the new trade flows, and a unidirectional ('orig') data frame with the welfare effects.
#' @export
#'
#' @examples
#'
#' flows <- expand.grid(LETTERS, LETTERS)
#' flows$flow <- 1
#' names(flows)[1:2] <- c("orig", "dest")
#'
#' # There should be no change in welfare (all ones)
#' out <- gravityGE::gravityGE(
#'   trade_data = flows,
#'   theta = 4,
#'   beta_hat_name = NULL,
#'   a_hat_name = NULL,
#'   multiplicative = FALSE
#' )
#'
#'
gravityGE <- function(
    trade_data,
    theta = 4,
    beta_hat_name = NULL,
    a_hat_name = NULL,
    multiplicative = FALSE
) {

  # ----: Algorithm parameters :----
  tol = 1e-8; max_iter = 1000000; crit = 1

  # ----: Stops :----
  # Check that trade_data is a data frame with the appropriate names
  if (is.data.frame(trade_data)) {
    if (!all(c("orig", "dest", "flow") %in% colnames(trade_data))) {
      stop("Data set must contain columns 'orig', 'dest', and 'flow'.")
    }
  } else {
    stop("Trade data set must be a data frame.")
  }

  # Check if trade_data contains duplicate origin-destination pairs
  if (nrow(trade_data) != length(unique(paste(trade_data$orig, trade_data$dest)))) {
    stop("Data set contains duplicate origin-destination pairs.")
  }

  if (any(trade_data$flow < 0)) stop("Negative flow values detected.")

  # Check if trade_data is square (i.e., each location has the same number of trade partners)
  N <- sqrt(nrow(trade_data))
  if (floor(N) != N) {
    stop("Non-square data set detected. The size of the data should be NxN. Check whether every location has N trade partners, including itself.")
  }

  ones_matrix <- as.matrix(rep(1, N), N) # A vector of ones to help with matrix operations

  # Re order, and then make the trade matrix with exporters (rows) and importers (columns)
  trade_data <- trade_data[order(trade_data$orig, trade_data$dest),]
  trade_matrix <- matrix(trade_data$flow, nrow = N, byrow = TRUE)

  # Check that beta_hat_name is in trade_data, and if NULL create it.
  if (!is.null(beta_hat_name)) { # If exists

    if (!is.character(beta_hat_name)) stop("beta_hat_name must be a character name in trade_data.")
    beta_matrix <- matrix(trade_data[[beta_hat_name]], nrow = N, ncol = N)

    if (any(diag(beta_matrix) != 0)) stop("Diagonal values of beta_hat must be zero.")
    beta_matrix <- exp(beta_matrix)

    if (any(beta_matrix < 0)) stop("Negative beta values detected.")

  }else{ # If does not exist
    beta_matrix <- matrix(rep(1, N*N), nrow = N, ncol = N) # exp(0) = 1
  }

  # Check if a_hat is in trade_data, and if NULL create it
  if (!is.null(a_hat_name)) {# If exists

    if (!is.character(a_hat_name)) stop("a_hat_name must be a character name in trade_data.")

    # Check to see that all values across 'orig' in a_hat are the same
    for(o in unique(trade_data$orig)) {
      if (length(unique(trade_data[[a_hat_name]][trade_data$orig == o])) != 1) {
        stop("a_hat must have the same value for each 'orig'.")
      }
    }

    a_hat <- stats::aggregate(trade_data[[a_hat_name]], by = list(trade_data$orig), FUN = mean)
    a_hat <- matrix(a_hat$x, nrow = N, ncol = 1)
    if (any(a_hat < 0)) stop("Negative a_hat values detected.")
    a_matrix <- a_hat

  }else{ # If doesn't exist
    a_matrix <- ones_matrix
  }

  # ----: Warnings :----
  # Check for zero home flows (for all i = j)
  if (min(diag(trade_matrix)) == 0) warning("Zero flow values detected.")
  trade_matrix[is.na(trade_matrix)] <- 0

  # ----: Algorithm :----
  # Initialize values
  X <- trade_matrix # Trade
  w_hat <- ones_matrix # Wages
  P_hat <- ones_matrix # Prices
  E <- t(t(ones_matrix) %*% X) # Expenditure (col summation)
  Y <- X %*% ones_matrix # Income (row summation)
  D <- E - Y

  pi <- X / kronecker(t(E), ones_matrix)  # Shares
  B <- beta_matrix

  # ----: Adding col and row names to matrices :----
  orig_ls <- unique(trade_data$orig)
  colnames(X) <- orig_ls
  rownames(X) <- orig_ls
  rownames(w_hat) <- orig_ls
  rownames(P_hat) <- orig_ls
  rownames(E) <- orig_ls
  rownames(Y) <- orig_ls
  rownames(D) <- orig_ls
  rownames(pi) <- orig_ls
  colnames(pi) <- orig_ls
  rownames(B) <- orig_ls
  colnames(B) <- orig_ls

  # Iterative procedure
  iter <- 0
  while (crit > tol && iter < max_iter) {

    iter <- iter + 1
    X_last_step <- X

    # Step 1: Update w_hat
    w_hat <- (a_matrix * ((pi * B) %*% (E / P_hat)) / Y)^(1 / (1 + theta))

    # Step 1.5: Normalize w_hat so that total world output stays the same
    w_hat <- w_hat * (sum(Y) / sum(Y * w_hat))

    # Step 2: Update P_hat
    P_hat <- (t(pi) * t(B)) %*% (a_matrix * (w_hat^(-theta)))

    # Step 3: Update E
    if (multiplicative) {
      E <- (Y + D) * w_hat
    } else {
      E <- Y * w_hat + D
    }

    # Step 4: Update pi and trade_matrix
    pi_new <- (pi * B) * (kronecker(a_matrix * (w_hat^(-theta)),  t(ones_matrix))) / (kronecker(P_hat, t(ones_matrix)))

    X <- pi_new * kronecker(t(E), ones_matrix)

    # Convergence criterion
#    browser()
    crit <- max(abs(log(X) - log(X_last_step)), na.rm = TRUE)
  }

  if (iter == max_iter) warning("Maximum iterations reached without convergence.")

  # ----: Compute welfare effects :----
  real_wage <- w_hat / (P_hat^(-1 / theta))
  if (multiplicative) {
    welfare <- real_wage
  } else {
    welfare <- ((Y * w_hat) + D) / (Y + D) / (P_hat^(-1 / theta))
  }

  # ----: Format outputs :----
  out1_df <- data.frame( # New trade
    orig = trade_data$orig,
    dest = trade_data$dest,
    new_trade = as.vector(t(X))
  )

  out2_df <- data.frame( # New welfare
    orig = unique(trade_data$orig),
    welfare = as.vector(welfare),
    nominal_wage = as.vector(w_hat),
    price_index = as.vector(P_hat^(-1 / theta))
  )

  return(
    list(
      new_trade = out1_df,
      new_welfare = out2_df
    )
  )

}
