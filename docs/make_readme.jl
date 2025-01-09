using Literate: Literate
using MapBroadcast: MapBroadcast

Literate.markdown(
  joinpath(pkgdir(MapBroadcast), "examples", "README.jl"),
  joinpath(pkgdir(MapBroadcast));
  flavor=Literate.CommonMarkFlavor(),
  name="README",
)
