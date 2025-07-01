module GravityGE
export gravityGE
using DataFrames, LinearAlgebra, Statistics

include("initializers.jl")


include("model.jl")

export gravityGE

include("original_model.jl")
export original_gravityGE


end # module gravityGE