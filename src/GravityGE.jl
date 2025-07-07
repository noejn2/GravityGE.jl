"""
GravityGE module to implement a gravity model for trade data using General Equilibrium (GE) methods.
This module provides functionality to analyze trade flows between countries based on their economic characteristics.

"""

module GravityGE

export gravityGE
using DataFrames, LinearAlgebra, Statistics

include("initializers.jl") # Helper functions
include("TradeData.jl") # TradeData Struct
include("model.jl") # Main model

export gravityGE

end # module GravityGE
