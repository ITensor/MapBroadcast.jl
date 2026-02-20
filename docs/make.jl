using Documenter: Documenter, DocMeta, deploydocs, makedocs
using MapBroadcast: MapBroadcast

DocMeta.setdocmeta!(MapBroadcast, :DocTestSetup, :(using MapBroadcast); recursive = true)

include("make_index.jl")

makedocs(;
    modules = [MapBroadcast],
    authors = "ITensor developers <support@itensor.org> and contributors",
    sitename = "MapBroadcast.jl",
    format = Documenter.HTML(;
        canonical = "https://itensor.github.io/MapBroadcast.jl",
        edit_link = "main",
        assets = ["assets/favicon.ico", "assets/extras.css"]
    ),
    pages = ["Home" => "index.md", "Reference" => "reference.md"]
)

deploydocs(;
    repo = "github.com/ITensor/MapBroadcast.jl",
    devbranch = "main",
    push_preview = true
)
