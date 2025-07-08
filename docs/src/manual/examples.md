# Examples

This page provides comprehensive examples of using GravityGE.jl for different types of trade analysis.

## Basic Trade Analysis

### Simple Two-Country Model

```julia
using GravityGE
using DataFrames

# Create bilateral trade data for USA and Canada
trade_data = DataFrame(
    origin = ["USA", "USA", "CAN", "CAN"],
    destination = ["USA", "CAN", "USA", "CAN"],
    value = [500.0, 100.0, 80.0, 200.0]
)

# Run basic gravity GE analysis
result = gravityGE(trade_data; theta=4.0)

# Examine results
println("Welfare changes:")
println(result[:new_welfare])

println("\nWage changes:")
println(result[:new_wages])
```

### Multi-Country Analysis

```julia
# Create data for multiple countries
countries = ["USA", "CAN", "MEX", "BRA"]
n_countries = length(countries)

# Generate all bilateral pairs
origins = repeat(countries, inner=n_countries)
destinations = repeat(countries, outer=n_countries)

# Sample trade values (in practice, use real data)
trade_values = [
    500.0, 100.0, 50.0, 30.0,   # USA exports
    80.0,  200.0, 20.0, 15.0,   # CAN exports
    40.0,  25.0,  150.0, 10.0,  # MEX exports
    20.0,  12.0,  8.0,   100.0  # BRA exports
]

multi_trade = DataFrame(
    origin = origins,
    destination = destinations,
    value = trade_values
)

# Analyze multi-country trade
result = gravityGE(multi_trade; theta=5.0)
```

## Productivity Shock Analysis

### Uniform Productivity Increase

```julia
# Add productivity shock column
trade_data.productivity = [1.1, 1.1, 1.1, 1.1]  # 10% increase for all

# Run analysis with productivity shocks
result = gravityGE(trade_data; theta=4.0, a_hat_name="productivity")

println("Welfare effects of 10% productivity increase:")
println(result[:new_welfare])
```

### Country-Specific Productivity Shocks

```julia
# Create data with country-specific shocks
trade_data = DataFrame(
    origin = ["USA", "USA", "CAN", "CAN"],
    destination = ["USA", "CAN", "USA", "CAN"],
    value = [500.0, 100.0, 80.0, 200.0],
    productivity = [1.2, 1.2, 0.9, 0.9]  # USA +20%, CAN -10%
)

result = gravityGE(trade_data; theta=4.0, a_hat_name="productivity")

println("Asymmetric productivity shock effects:")
for (i, country) in enumerate(["USA", "CAN"])
    welfare = result[:new_welfare].welfare[i]
    println("$country welfare change: $(round(welfare, digits=3))")
end
```

## Trade Cost Shock Analysis

### Bilateral Trade Cost Reduction

```julia
# Create trade cost shock data
trade_data = DataFrame(
    origin = ["USA", "USA", "CAN", "CAN"],
    destination = ["USA", "CAN", "USA", "CAN"],
    value = [500.0, 100.0, 80.0, 200.0],
    trade_costs = [0.0, -0.2, -0.2, 0.0]  # 20% bilateral cost reduction
)

result = gravityGE(trade_data; theta=4.0, beta_hat_name="trade_costs")

println("Effects of 20% bilateral trade cost reduction:")
println(result[:new_welfare])
```

### Regional Trade Agreement Simulation

```julia
# Simulate NAFTA-style agreement
countries = ["USA", "CAN", "MEX", "BRA"]
n = length(countries)

# Create full bilateral trade matrix
trade_matrix = DataFrame(
    origin = repeat(countries, inner=n),
    destination = repeat(countries, outer=n),
    value = [500, 100, 50, 30,   # USA
             80, 200, 20, 15,    # CAN
             40, 25, 150, 10,    # MEX
             20, 12, 8, 100]     # BRA
)

# NAFTA members get preferential treatment
nafta_members = ["USA", "CAN", "MEX"]
trade_matrix.trade_costs = zeros(nrow(trade_matrix))

for i in 1:nrow(trade_matrix)
    origin = trade_matrix.origin[i]
    dest = trade_matrix.destination[i]

    # Internal trade costs are always zero
    if origin == dest
        trade_matrix.trade_costs[i] = 0.0
    # NAFTA members get 30% cost reduction
    elseif origin in nafta_members && dest in nafta_members
        trade_matrix.trade_costs[i] = -0.3
    # Non-NAFTA trade unchanged
    else
        trade_matrix.trade_costs[i] = 0.0
    end
end

# Analyze regional trade agreement
result = gravityGE(trade_matrix; theta=4.0, beta_hat_name="trade_costs")

println("NAFTA simulation welfare effects:")
for (i, country) in enumerate(countries)
    welfare = result[:new_welfare].welfare[i]
    println("$country: $(round((welfare-1)*100, digits=1))%")
end
```

## Advanced Configuration

### Custom Convergence Settings

```julia
# Use stricter convergence criteria
result = gravityGE(
    trade_data;
    theta=4.0,
    tol=1e-10,          # Tighter tolerance
    max_iter=5000,      # More iterations allowed
    multiplicative=false # Additive deficits
)

# Check convergence
if haskey(result, :iterations)
    println("Converged in $(result[:iterations]) iterations")
end
```

### Sensitivity Analysis

```julia
# Test different theta values
theta_values = [2.0, 4.0, 6.0, 8.0]
welfare_sensitivity = Dict()

for theta in theta_values
    result = gravityGE(trade_data; theta=theta)
    welfare_sensitivity[theta] = result[:new_welfare].welfare
end

println("Welfare sensitivity to theta:")
for (theta, welfare) in welfare_sensitivity
    avg_welfare = mean(welfare)
    println("θ = $theta: Average welfare = $(round(avg_welfare, digits=3))")
end
```

## Working with Real Data

### Loading and Cleaning Data

```julia
using CSV

# Load real trade data
raw_data = CSV.read("bilateral_trade.csv", DataFrame)

# Clean the data
clean_data = dropmissing(raw_data, [:origin, :destination, :value])
clean_data = clean_data[clean_data.value .> 0, :]

# Ensure all countries have internal trade
countries = unique(vcat(clean_data.origin, clean_data.destination))
internal_trade = DataFrame(
    origin = countries,
    destination = countries,
    value = fill(1000.0, length(countries))  # Placeholder values
)

# Combine external and internal trade
full_data = vcat(clean_data, internal_trade)
full_data = unique(full_data, [:origin, :destination])

# Create TradeData object
td = TradeData(full_data)
println("Analysis ready for $(td.N) countries")
```

### Batch Analysis

```julia
# Analyze multiple scenarios
scenarios = [
    ("Baseline", Dict()),
    ("High Elasticity", Dict(:theta => 8.0)),
    ("Low Elasticity", Dict(:theta => 2.0)),
    ("Multiplicative", Dict(:multiplicative => true))
]

results = Dict()

for (name, params) in scenarios
    println("Running scenario: $name")
    result = gravityGE(trade_data; params...)
    results[name] = result[:new_welfare].welfare
end

# Compare results
println("\nScenario comparison (average welfare):")
for (name, welfare) in results
    avg = mean(welfare)
    println("$name: $(round(avg, digits=3))")
end
```
