# GravityGE.jl

Welcome to the documentation for **GravityGE.jl**!

This package solves a one-sector Armington-CES gravity model with general equilibrium. It is inspired by the R package [gravityGE](https://cran.r-project.org/package=gravityGE).

## Example

```julia
using GravityGE, DataFrames

flows = DataFrame(orig = ["A", "A", "B", "B"], dest = ["A", "B", "A", "B"], flow = [10.0, 5.0, 6.0, 4.0])
result = gravityGE(flows)
```