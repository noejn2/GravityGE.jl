using Documenter, GravityGE #, DataFrames, LinearAlgebra, Statistics

makedocs(;
    modules=[GravityGE],
    authors="Noé J Nava <noejnava2@gmail.com> and contributors",
    sitename="GravityGE.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://noejnava.github.io/GravityGE.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => [
            "Understanding input/output" => "manual/understanding.md",
            "Data Structures" => "manual/data-structures.md",
            "Examples" => "manual/examples.md",
        ],
        "API Reference" => [
            "Main Function" => "api/functions.md",
            # "Data Types" => "api/types.md",
            # "Utilities" => "api/utilities.md",
        ],
    ],
    repo="https://github.com/noejn2/GravityGE.jl/blob/{commit}{path}#L{line}",
    #remotes=nothing,
    checkdocs=:exports,
    doctest=true,
    linkcheck=true,
    #    strict=true,
)


deploydocs(;
    repo="github.com/noejnava/GravityGE.jl",
    devbranch="main",
    branch="gh-pages"
)