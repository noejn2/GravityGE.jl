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
function gravityGE(trade_data::DataFrame;
    theta::Float64=4.0,
    beta_hat_name::Union{Nothing,String}=nothing,
    a_hat_name::Union{Nothing,String}=nothing,
    multiplicative::Bool=false,
    tol=1e-8,
    max_iter=1_000_000,
    crit=1.0
)

    td = TradeData(trade_data) # Validate trade data

    sort!(td.df, ["origin", "destination"])
    X = reshape(trade_data.value, td.N, td.N)' # byrow = true

    B = if isnothing(beta_hat_name)
        ones(td.N, td.N) # Default beta matrix
    else
        beta_matrix(td.df, beta_hat_name, td.N)
    end

    A_matrix = if isnothing(a_hat_name)
        ones(td.N, 1) # Default a matrix
    else
        a_matrix(td.df, a_hat_name, td.N)
    end

    #= a_hat & beta_hat checks =#
    if !isnothing(a_hat_name)
        var_hat_checks(td.df, a_hat_name)
    end
    if !isnothing(beta_hat_name)
        var_hat_checks(td.df, beta_hat_name)
    end

    # check if a_hat values repeat across each origin region
    if !isnothing(a_hat_name)
        a_vec = td.df[:, a_hat_name]
        for i in unique(td.df.origin)
            if length(unique(a_vec[td.df.origin.==i])) != 1
                error("a_hat values must be constant for each origin region.")
            end
        end
    end

    # ----: Initialization :----
    w_hat = td.ones_vector
    P_hat = td.ones_vector
    E = sum(X, dims=1)' # expenditure
    Y = sum(X, dims=2)  # income
    D = E - Y

    pi = X ./ kron(E', td.ones_vector)         # shares
    iter = 0

    while crit > tol && iter < max_iter
        iter += 1
        X_last_step = copy(X)

        w_hat = (A_matrix .* ((pi .* B) * (E ./ P_hat)) ./ Y) .^ (1 / (1 + theta))
        w_hat *= sum(Y) / sum(Y .* w_hat)

        P_hat = (pi' .* B') * (A_matrix .* w_hat .^ (-theta))

        if multiplicative
            E = (Y + D) .* w_hat
        else
            E = Y .* w_hat + D
        end

        pi_new = (pi .* B) .* (kron(A_matrix .* (w_hat .^ (-theta)), td.ones_vector')) ./ kron(P_hat, td.ones_vector')
        X = pi_new .* kron(E', td.ones_vector)

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
    origs = repeat(unique(trade_data.origin), inner=td.N)
    dests = repeat(unique(trade_data.destination), outer=td.N)

    new_trade = DataFrame(orig=origs, dest=dests, new_trade=vec(X'))
    new_welfare = DataFrame(
        orig=unique(trade_data.origin),
        welfare=vec(welfare),
        nominal_wage=vec(w_hat),
        price_index=vec(P_hat .^ (-1 / theta))
    )

    return Dict(
        :new_trade => new_trade,
        :new_welfare => new_welfare
    )
end