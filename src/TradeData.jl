#= Unmutable dataframe: region lists, trade flow values, a_hat (productivity), and beta_hat (trade costs) =#
struct TradeData
    df::DataFrame

    # Validation and invariant checks (Inner constructor)
    function TradeData(df::DataFrame)

        # = Region checks =#
        # Check Names
        required_cols = ["origin", "destination", "value"]
        if !all(col -> lowercase(col) in names(df), required_cols)
            error("Data set must contain columns $(required_cols)")
        end

        # Check column types
        if !(eltype(df.origin) <: AbstractString) || !(eltype(df.destination) <: AbstractString)
            error("Columns 'origin' and 'destination' must be of type String.")
        end

        # Check for duplicate pairs
        if nrow(df) != nrow(unique(df[:, ["origin", "destination"]]))
            error("Data set contains duplicate origin-destination pairs.")
        end

        #= Trade flow checks =#
        if !(eltype(df.value) <: Real)
            error("Column 'value' must be of a numeric type (Real).")
        end

        # check for non-numeric values in value
        if any(x -> isinf(x) || ismissing(x) || isnan(x), df.value)
            error("Non-numeric values detected in value.")
        end

        # Check for negative values
        if any(x -> x < 0, df.value)
            error("Negative value values detected.")
        end

        # Check for zero flows in Diagonal
        if any(row -> row.value == 0, eachrow(df[df.origin.==df.destination, :]))
            error("Non-zero flows detected between identical regions.")
        end
        return new(df)
    end

end

# Lazy initializations
function Base.getproperty(
    td::TradeData,
    name::Symbol
)
    if name == :N # Number of regions
        return union(td.df.origin, td.df.destination) |> length
    elseif name == :ones_vector # Create a vector of ones
        N = union(td.df.origin, td.df.destination) |> length
        return ones(N, 1)
    elseif name == :ones_matrix
        N = union(td.df.origin, td.df.destination) |> length
        return ones(N, N)
    elseif name == :df
        return getfield(td, :df)
    else
        throw(ArgumentError("Unknown property: $name"))
    end
end