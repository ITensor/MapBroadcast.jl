# MapBroadcast.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://ITensor.github.io/MapBroadcast.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ITensor.github.io/MapBroadcast.jl/dev/)
[![Build Status](https://github.com/ITensor/MapBroadcast.jl/actions/workflows/Tests.yml/badge.svg?branch=main)](https://github.com/ITensor/MapBroadcast.jl/actions/workflows/Tests.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/ITensor/MapBroadcast.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ITensor/MapBroadcast.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## Installation instructions

This package resides in the `ITensor/ITensorRegistry` local registry.
In order to install, simply add that registry through your package manager.
This step is only required once.
```julia
julia> using Pkg: Pkg

julia> Pkg.Registry.add(url="https://github.com/ITensor/ITensorRegistry")
```
or:
```julia
julia> Pkg.Registry.add(url="git@github.com:ITensor/ITensorRegistry.git")
```
if you want to use SSH credentials, which can make it so you don't have to enter your Github ursername and password when registering packages.

Then, the package can be added as usual through the package manager:

```julia
julia> Pkg.add("MapBroadcast")
```

## Examples

````julia
using Base.Broadcast: broadcasted
using MapBroadcast: Mapped, mapped
using Test: @test

a = randn(2, 2)
bc = broadcasted(*, 2, a)
m = Mapped(bc)
m′ = mapped(x -> 2x, a)
@test copy(m) ≈ map(m.f, m.args...)
@test copy(m) ≈ copy(m′)
@test copy(m) ≈ copy(bc)
@test axes(m) == axes(bc)
@test copyto!(similar(m, Float64), m) ≈ copyto!(similar(bc, Float64), bc)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

