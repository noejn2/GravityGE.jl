# GravityGE.jl

*A Julia package for gravity models in international trade with general equilibrium effects.*


## Documentation

For detailed documentation, examples, and API reference, visit the stable documentation:

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://noejnava.github.io/GravityGE.jl/)




## Overview

GravityGE.jl implements gravity models for analyzing bilateral trade flows with general equilibrium effects. This package is a Julia translation of the [gravityGE R package](https://cran.r-project.org/package=gravityGE).

The package provides tools for:

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
result = gravityGE(trade_data; theta=4.0)

# Access welfare effects
println("Welfare changes: ", result[:new_welfare])
```

## Advanced Usage

### With Trade Cost Shocks

```julia
# Add trade cost shocks (beta_hat)
trade_data.trade_costs = [0.0, -0.2, -0.2, 0.0]  # 20% cost reduction

# Run analysis with trade cost shocks
result = gravityGE(trade_data; theta=4.0, beta_hat_name="trade_costs")
```

### With Productivity Shocks

```julia
# Add productivity shocks (a_hat)
trade_data.productivity = [1.1, 1.1, 0.9, 0.9]  # USA +10%, CAN -10%

# Run analysis with productivity shocks
result = gravityGE(trade_data; theta=4.0, a_hat_name="productivity")
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

