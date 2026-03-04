using Documenter: Documenter, DocMeta, deploydocs, makedocs
using ITensorFormatter: ITensorFormatter
using MapBroadcast: MapBroadcast

DocMeta.setdocmeta!(MapBroadcast, :DocTestSetup, :(using MapBroadcast); recursive = true)

ITensorFormatter.make_index!(pkgdir(MapBroadcast))

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
