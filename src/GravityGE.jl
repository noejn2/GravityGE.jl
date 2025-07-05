module GravityGE

export gravityGE
using DataFrames, LinearAlgebra, Statistics, Infiltrator

include("initializers.jl") # Helper functions
include("TradeData.jl") # TradeData Struct
include("model.jl") # Main model

export gravityGE

end # module GravityGE
