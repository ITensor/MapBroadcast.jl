using MapBroadcast: MapBroadcast
using Documenter: Documenter, DocMeta, deploydocs, makedocs

DocMeta.setdocmeta!(MapBroadcast, :DocTestSetup, :(using MapBroadcast); recursive=true)

include("make_index.jl")

makedocs(;
  modules=[MapBroadcast],
  authors="ITensor developers <support@itensor.org> and contributors",
  sitename="MapBroadcast.jl",
  format=Documenter.HTML(;
    canonical="https://ITensor.github.io/MapBroadcast.jl", edit_link="main", assets=String[]
  ),
  pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/ITensor/MapBroadcast.jl", devbranch="main", push_preview=true)
