# Checks of a_hat and beta_hat values within struct TradeData
function var_hat_checks(
    df::DataFrame,
    var_hat_name::Union{Nothing,String}=nothing
)
    if !isnothing(var_hat_name)
        if !(var_hat_name in names(df))
            error("$(var_hat_name) must be a valid column in dataframe.")
        end

        if !(eltype(df[:, var_hat_name]) <: Real)
            error("Column var_hat_name must be of a numeric type (Real).")
        end

        if any(x -> isinf(x) || ismissing(x) || isnan(x), df[:, var_hat_name])
            error("Non-numeric values detected in var_hat.")
        end
    else
        return nothing
    end

end

# Create beta_hat matrix within model.jl
function beta_matrix(
    trade_data::DataFrame,
    beta_hat_name::String,
    N::Int
)

    # if !(beta_hat_name in names(trade_data))
    #     error("beta_hat_name must be a valid column in trade_data.")
    # end
    beta_vec = trade_data[:, beta_hat_name]
    beta_matrix = reshape(beta_vec, N, N)
    if any(diag(beta_matrix) .!= 0)
        error("Origin = destination values of beta_hat must be zero.")
    end
    beta_matrix = exp.(beta_matrix) # Ensure positive values
    return beta_matrix
end

function a_matrix(
    df::DataFrame,
    a_hat_name::String,
    N::Int
)

    a_vec = df |>
            x -> subset(x, [:origin, :destination] => ByRow((o, d) -> o == d)
    ) |>
                 x -> x[:, a_hat_name]

    if any(a_vec .< 0)
        error("Negative a_hat values detected.")
    end

    a_matrix = reshape(a_vec, N, 1)
    return a_matrix

end