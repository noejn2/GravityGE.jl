using Documenter
using GravityGE

makedocs(
    sitename="GravityGE.jl",
    format=Documenter.HTML(),
    modules=[GravityGE],
    pages=[
        "Home" => "index.md",
    ],
    repo="github.com/noejn2/GravityGE.jl",  # 👈 this fixes the error
)

deploydocs(
    repo="github.com/noejn2/GravityGE.jl",
    branch="gh-pages",
    devbranch="main",
    push_preview=false,
)
