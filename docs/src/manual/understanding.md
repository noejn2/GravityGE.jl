# Understanding input and outputs

This guide will help you get started with GravityGE.jl for analyzing bilateral trade flows using gravity models with general equilibrium effects.

## Key Parameters

- `theta`: Trade elasticity parameter (higher values = more substitutable goods)
- `tol`: Convergence tolerance (default: 1e-6)
- `max_iter`: Maximum iterations (default: 1000)
- `multiplicative`: Whether to use multiplicative deficits (default: false)

## Understanding Results

The `gravityGE` function returns a dictionary with:

- `:new_welfare`: Welfare changes by region
- `:new_wages`: Wage changes (normalized)
- `:new_prices`: Price index changes
- `:new_trade_flows`: Updated bilateral trade flows

