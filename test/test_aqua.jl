using Aqua: Aqua
using MapBroadcast: MapBroadcast
using Test: @testset

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(MapBroadcast)
end
