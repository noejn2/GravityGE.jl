# Data Structures

GravityGE.jl uses structured data validation to ensure your trade data meets the requirements for gravity model analysis.

## TradeData Structure

The `TradeData` struct is the core data container that validates and stores your trade flow information.

### Required Columns

Your DataFrame must contain these columns (case-insensitive):

| Column | Type | Description |
|--------|------|-------------|
| `origin` | String | Origin country/region identifier |
| `destination` | String | Destination country/region identifier |
| `value` | Numeric | Trade flow value (must be positive) |

### Optional Shock Columns

You can include additional columns for counterfactual analysis:

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `a_hat` | Numeric | Productivity shocks | Must be non-zero |
| `beta_hat` | Numeric | Trade cost shocks | Must be zero for internal flows |

## Data Validation Rules

### Basic Structure
- No duplicate origin-destination pairs
- All trade values must be positive and finite
- No missing values in required columns

### Internal Trade Flows
- Flows where `origin == destination` must be positive
- These represent internal/domestic trade within regions

### Productivity Shocks (a_hat)
- All values must be non-zero (no division by zero)
- Positive values indicate productivity increases
- Values < 1 indicate productivity decreases

### Trade Cost Shocks (beta_hat)
- Diagonal elements (internal flows) must be zero
- Negative values indicate trade cost reductions
- Positive values indicate trade cost increases

## Creating TradeData Objects

```julia
# Basic usage
td = TradeData(your_dataframe)

# With productivity shocks
td = TradeData(your_dataframe; a_hat_name="productivity")

# With trade cost shocks
td = TradeData(your_dataframe; beta_hat_name="trade_costs")

# With both types of shocks
td = TradeData(your_dataframe;
               a_hat_name="productivity",
               beta_hat_name="trade_costs")
```

## Accessing Properties

The `TradeData` struct provides convenient properties:

```julia
td = TradeData(your_data)

# Number of regions
println("Regions: ", td.N)

# Access underlying DataFrame
data = td.df

# Get matrices for calculations
ones_vec = td.ones_vector  # N×1 vector of ones
ones_mat = td.ones_matrix  # N×N matrix of ones
```

## Example Data Structure

```julia
# Well-formatted trade data
trade_data = DataFrame(
    origin = ["USA", "USA", "CAN", "CAN", "MEX", "MEX"],
    destination = ["USA", "CAN", "USA", "CAN", "USA", "CAN"],
    value = [500.0, 100.0, 80.0, 200.0, 50.0, 30.0],
    productivity = [1.0, 1.1, 0.9, 1.05, 1.2, 0.95],
    trade_costs = [0.0, -0.1, -0.05, 0.0, -0.15, -0.08]
)

# Create validated TradeData object
td = TradeData(trade_data;
               a_hat_name="productivity",
               beta_hat_name="trade_costs")
```

## Common Data Issues

### Duplicate Pairs
```julia
# ❌ This will fail - duplicate USA→CAN
bad_data = DataFrame(
    origin = ["USA", "USA", "USA"],
    destination = ["CAN", "CAN", "MEX"],
    value = [100.0, 50.0, 75.0]
)
```

### Missing Internal Trade
```julia
# ❌ This will fail - missing USA→USA flow
incomplete_data = DataFrame(
    origin = ["USA", "CAN"],
    destination = ["CAN", "USA"],
    value = [100.0, 50.0]
)
```

### Invalid Trade Costs
```julia
# ❌ This will fail - non-zero internal trade cost
invalid_costs = DataFrame(
    origin = ["USA", "USA"],
    destination = ["USA", "CAN"],
    value = [100.0, 50.0],
    trade_costs = [-0.1, -0.05]  # Internal flow should be 0.0
)
```
