#= Unmutable dataframe: region lists, trade flow values, a_hat (productivity), and beta_hat (trade costs) =#
struct TradeData
    df::DataFrame

    # Validation and invariant checks (Inner constructor)
    function TradeData(df::DataFrame;
        a_hat_name::Union{Nothing,String}=nothing,
        beta_hat_name::Union{Nothing,String}=nothing
    )

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

        # check for zeros in diagonals (origin == destination)
        if any(row -> row.value == 0, eachrow(df[df.origin.==df.destination, :]))
            error("Non-zero flows detected between identical regions.")
        end

        # Further checks on trade values
        variable_checks(df[:, "value"])

        #= a_hat checks =#
        if !isnothing(a_hat_name)
            # non-zero values
            if any(row -> row[a_hat_name] == 0, eachrow(df))
                error("All a_hat values must not be zero.")
            end

            # Further checks on a_hat values
            variable_checks(df[:, a_hat_name])

        end

        #= beta_hat checks =#
        if !isnothing(beta_hat_name)
            # check for non-zero in diagonals (origin == destination)
            if any(row -> row[beta_hat_name] != 0, eachrow(df[df.origin.==df.destination, :]))
                error("Flows between identical regions must be zero.")
            end

            # Further checks on beta_hat values
            variable_checks(exp.(df[:, beta_hat_name]))

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

    elseif name == :ones_matrix # Create a symmetric matrix of ones
        N = union(td.df.origin, td.df.destination) |> length
        return ones(N, N)

    elseif name == :df # Default DataFrame
        return getfield(td, :df)
    else
        throw(ArgumentError("Unknown property: $name"))
    end
end