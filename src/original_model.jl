"""
    gravityGE(
        trade_data::DataFrame; 
        theta=4.0, 
        beta_hat_name=nothing, 
        a_hat_name=nothing, 
        multiplicative=false,
        tol = 1e-8,
        max_iter = 1_000_000,
        crit = 1.0
    )

Solve a one-sector Armington-CES gravity model with general equilibrium closure.

# Arguments
- `trade_data::DataFrame`: A `DataFrame` containing trade flows and (optionally) trade frictions and productivity. It must contain the columns `"orig"`, `"dest"`, and `"flow"`.
- `theta::Float64=4.0`: Trade elasticity parameter.
- `beta_hat_name::Union{Nothing,String}`: (Optional) Column name for bilateral trade frictions in log form. Should be zero on the diagonal.
- `a_hat_name::Union{Nothing,String}`: (Optional) Column name for log productivity. Must be positive and match regions along the diagonal.
- `multiplicative::Bool=false`: If `true`, assumes a multiplicative GE closure; otherwise, uses an additive closure.
- `tol::Float64=1e-8`: Convergence tolerance.
- `max_iter::Int=1_000_000`: Maximum number of iterations for convergence
- `crit::Float64=1.0`: Initial convergence criterion.

# Returns
A `Dict` with two elements:
- `:new_trade` – a `DataFrame` with updated bilateral trade flows.
- `:new_welfare` – a `DataFrame` with welfare, nominal wages, and price indexes by region.

## Example:

`julia
using DataFrames, GravityGE

flows = DataFrame(
        orig=repeat(string.('A':'Z'), inner=26),
        dest=repeat(string.('A':'Z'), outer=26),
        flow=ones(26^2)
    )

    # No change: additive
    out = gravityGE(flows; theta=4.0)

`
"""
function original_gravityGE(trade_data::DataFrame;
    theta::Float64=4.0,
    beta_hat_name::Union{Nothing,String}=nothing,
    a_hat_name::Union{Nothing,String}=nothing,
    multiplicative::Bool=false,
    tol = 1e-8,
    max_iter = 1_000_000,
    crit = 1.0
    )

    # ----: Validations :----
    required_cols = ["orig", "dest", "flow"]
    if !all(col -> col ∈ names(trade_data), required_cols)
        error("Data set must contain columns 'orig', 'dest', and 'flow'.")
    end

    if any(x -> x < 0, trade_data.flow)
        error("Negative flow values detected.")
    end

    pairs = string.(trade_data.orig) .* "_" .* string.(trade_data.dest)
    if length(pairs) != length(unique(pairs))
        error("Data set contains duplicate origin-destination pairs.")
    end

    N = Int(sqrt(nrow(trade_data)))
    if N * N != nrow(trade_data)
        error("Non-square data set detected. The size of the data should be NxN.")
    end

    ones_matrix = ones(N, 1)


    # ----: Reshape trade matrix :----
    sort!(trade_data, ["orig", "dest"])
    X = reshape(trade_data.flow, N, N)' # byrow = true

    # ----: Beta matrix :----
    if isnothing(beta_hat_name)
        B = ones(N, N)
    else
        if !(beta_hat_name in names(trade_data))
            error("beta_hat_name must be a valid column in trade_data.")
        end
        beta_vec = trade_data[:, beta_hat_name]
        beta_matrix = reshape(beta_vec, N, N)
        if any(diag(beta_matrix) .!= 0)
            error("Diagonal values of beta_hat must be zero.")
        end
        beta_matrix = exp.(beta_matrix) # Ensure positive values
        if any(beta_matrix .< 0)
            error("Negative beta values detected.")
        end
        B = beta_matrix
    end

    # ----: a_hat vector :----
    if isnothing(a_hat_name)
        a_matrix = ones_matrix
    else
        if !(a_hat_name in names(trade_data))
            error("a_hat_name must be a valid column in trade_data.")
        end
        a_vec = trade_data[:, a_hat_name][trade_data.orig.==trade_data.dest]

        #a_col = trade_data[:, a_hat_name]
        #        a_vec = [mean(a_col[trade_data.orig.==o]) for o in unique(trade_data.orig)]
        if any(a_vec .< 0)
            error("Negative a_hat values detected.")
        end
        a_matrix = reshape(a_vec, N, 1)
    end

    # ----: Warn on zero diagonals :----
    if minimum(diag(X)) == 0
        @warn("Zero flow values detected in diagonal.")
    end
    replace!(X, NaN => 0.0)

    # ----: Initialization :----
    w_hat = ones_matrix
    P_hat = ones_matrix
    E = sum(X, dims=1)' # expenditure
    Y = sum(X, dims=2)  # income
    D = E - Y

    pi = X ./ kron(E', ones_matrix)         # shares
    iter = 0

    while crit > tol && iter < max_iter
        iter += 1
        X_last_step = copy(X)

        w_hat = (a_matrix .* ((pi .* B) * (E ./ P_hat)) ./ Y) .^ (1 / (1 + theta))
        w_hat *= sum(Y) / sum(Y .* w_hat)

        P_hat = (pi' .* B') * (a_matrix .* w_hat .^ (-theta))

        if multiplicative
            E = (Y + D) .* w_hat
        else
            E = Y .* w_hat + D
        end

        pi_new = (pi .* B) .* (kron(a_matrix .* (w_hat .^ (-theta)), ones_matrix')) ./ kron(P_hat, ones_matrix')
        X = pi_new .* kron(E', ones_matrix)

        crit = maximum(filter(!isnan, abs.(log.(X) .- log.(X_last_step))))
    end

    if iter == max_iter
        @warn("Maximum iterations reached without convergence.")
    end

    real_wage = w_hat ./ (P_hat .^ (-1 / theta))
    welfare = if multiplicative
        real_wage
    else
        ((Y .* w_hat) .+ D) ./ (Y .+ D) ./ (P_hat .^ (-1 / theta))
    end

    # ----: Return results :----
    origs = repeat(unique(trade_data.orig), inner=N)
    dests = repeat(unique(trade_data.dest), outer=N)

    new_trade = DataFrame(orig=origs, dest=dests, new_trade=vec(X'))
    new_welfare = DataFrame(
        orig=unique(trade_data.orig),
        welfare=vec(welfare),
        nominal_wage=vec(w_hat),
        price_index=vec(P_hat .^ (-1 / theta))
    )

    return Dict(
        :new_trade => new_trade,
        :new_welfare => new_welfare
    )
end