function get_number_countries(df::DataFrame)
    N = length(unique(df[:, "orig"]) ∪ unique(df[:, "dest"]))
    return N
end

function beta_matrix(trade_data::DataFrame, ::Nothing)
    N = get_number_countries(trade_data)
    return ones(N,N)
end

function beta_matrix(trade_data::DataFrame, beta_hat_name::String)
    N = get_number_countries(trade_data)

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
    return beta_matrix
end


function a_matrix(trade_data::DataFrame, ::Nothing)
    N = get_number_countries(trade_data)
    return ones(N, 1)
end


function a_matrix(trade_data::DataFrame, a_hat_name::String)

    N = get_number_countries(trade_data)
      if isnothing(a_hat_name)
        a_matrix = ones_matrix
    else
        if !(a_hat_name in names(trade_data))
            error("a_hat_name must be a valid column in trade_data.")
        end
        
        a_vec = df |>
                    x-> subset(x,
                        [:orig, :dest] => ByRow((o,d) -> o==d)
                    ) |>
                    x -> x[:, a_hat_name]

        if any(a_vec .< 0)
            error("Negative a_hat values detected.")
        end
        a_matrix = reshape(a_vec, N, 1)
    end
    return a_matrix
end