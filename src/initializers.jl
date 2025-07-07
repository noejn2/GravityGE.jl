# Checks of a_hat and beta_hat values within struct TradeData
function variable_checks(
    vector::Vector{<:Real}
)

    if !(eltype(vector) <: Real)
        error("Column 'value' must be of a numeric type (Real).")
    end
    if any(x -> isinf(x) || ismissing(x) || isnan(x), vector)
        error("Non-numeric values detected in value.")
    end
    if any(x -> x < 0, vector)
        error("Negative value values detected.")
    end

end

function is_square_trade_matrix(df::DataFrame)

    all_regions = union(df.origin, df.destination)
    expected_pairs = Set((o, d) for o in all_regions, d in all_regions)

    return length(expected_pairs) == length(df.origin)
end

function complete_square_matrix(
    df::DataFrame,
    a_hat_name::Union{Nothing,String}=nothing,
    beta_hat_name::Union{Nothing,String}=nothing
)

    all_regions = union(df.origin, df.destination)
    df_square = DataFrame(
        origin=repeat(all_regions, inner=length(all_regions)),
        destination=repeat(all_regions, outer=length(all_regions))
    )
    leftjoin!(df_square, df, on=[:origin, :destination], makeunique=true)
    df_square.value[ismissing.(df_square.value)] .= 0.0

    if !isnothing(a_hat_name)
        df_square[!, a_hat_name][ismissing.(df_square[!, a_hat_name])] .= 1.0
    end

    if !isnothing(beta_hat_name)
        df_square[!, beta_hat_name][ismissing.(df_square[!, beta_hat_name])] .= 0
    end

    return df_square
end


# Create beta_hat matrix within model.jl
function beta_matrix(
    trade_data::DataFrame,
    beta_hat_name::String,
    N::Int
)
    beta_vec = trade_data[:, beta_hat_name]
    beta_matrix = reshape(beta_vec, N, N)

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

    a_matrix = reshape(a_vec, N, 1)
    return a_matrix

end
