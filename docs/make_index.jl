using Literate: Literate
using MapBroadcast: MapBroadcast

Literate.markdown(
  joinpath(pkgdir(MapBroadcast), "examples", "README.jl"),
  joinpath(pkgdir(MapBroadcast), "docs", "src");
  flavor=Literate.DocumenterFlavor(),
  name="index",
)
