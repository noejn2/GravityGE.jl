# GravityGE.jl

*A Julia package for gravity models in international trade with general equilibrium effects.*

## Overview

GravityGE.jl implements gravity models for analyzing bilateral trade flows with general equilibrium effects. The package provides tools for:

- **Bilateral Trade Analysis**: Analyze trade flows between countries/regions
- **General Equilibrium Effects**: Account for wage and price adjustments
- **Counterfactual Analysis**: Simulate productivity and trade cost shocks
- **Welfare Analysis**: Compute welfare effects of trade policy changes

## Key Features

- **Validated Data Structures**: Comprehensive validation of trade flow data
- **Flexible Shock Analysis**: Support for productivity (`a_hat`) and trade cost (`beta_hat`) shocks
- **Convergence Guarantees**: Robust numerical methods with configurable tolerance
- **Policy Simulation**: Tools for analyzing trade agreements and policy reforms

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/noejn2/GravityGE.jl")
```

## Quick Start

```julia
using GravityGE
using DataFrames

# Create bilateral trade data
trade_data = DataFrame(
    origin = ["USA", "USA", "CAN", "CAN"],
    destination = ["USA", "CAN", "USA", "CAN"],
    value = [500.0, 100.0, 80.0, 200.0]
)

# Run gravity GE analysis
theta_value=4.0 # Trade elasticity assumed to be 4.0
result = gravityGE(trade_data; theta=theta_value)

# Access welfare effects (all ones since no simulation shocked is assumed)
println("Welfare changes: ", result[:new_welfare])

# Run gravity GE analysis assuming trade costs between USA and CAN increased by 50%
trade_data.bitrade .= -1*theta_value*log(1.5)
trade.bitrade[trade.origin == trade.destination ] .= 0
result = gravityGE(trade_data; theta=theta_value, beta_hat_name="bitrade")
println("Welfare changes: ", result[:new_welfare])

# Run gravity GE analysis assuming trade costs between USA and CAN increased by 50% and productivity in the USA and CAN falls
trade_data.prod = 0.5
result = gravityGE(trade_data; theta=theta_value, beta_hat_name="bitrade", a_hat_name="prod")
println("Welfare changes: ", result[:new_welfare])



```

## Package Structure

The package is organized around several key components:

```@contents
Pages = [
    "manual/getting-started.md",
    "manual/data-structures.md",
    "manual/examples.md",
    "api/functions.md",
    "api/types.md",
    "api/utilities.md"
]
Depth = 2
```

## Citation

If you use GravityGE.jl in your research, please cite:

```bibtex
@software{gravityge_jl,
  author = {Nava, Noé J.},
  title = {GravityGE.jl: A Julia Package for Gravity Models with General Equilibrium Effects},
  url = {https://github.com/noejn2/GravityGE.jl},
  version = {0.1.0},
  year = {2025}
}
```

## License

This package is licensed under the MIT License.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Related Packages

- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) - Data manipulation
- [LinearAlgebra.jl](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/) - Linear algebra operations
- [Statistics.jl](https://docs.julialang.org/en/v1/stdlib/Statistics/) - Statistical functions