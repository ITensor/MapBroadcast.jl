using Base.Broadcast:
  BroadcastStyle, Broadcasted, broadcastable, broadcasted, materialize, materialize!
using FillArrays: Fill
using MapBroadcast:
  LinearCombination, Mapped, Summed, arguments, coefficients, is_map_expr, mapped, style
using Test: @inferred, @test, @test_throws, @testset

@testset "MapBroadcast (eltype=$elt)" for elt in (
  Float32, Float64, Complex{Float32}, Complex{Float64}
)
  c = elt(2.2)
  a = randn(elt, 2, 3)
  b = randn(elt, 2, 3)
  for (bc, m′, ref) in (
    (broadcasted(*, c, a), mapped(x -> c * x, a), c * a),
    (broadcasted(+, a, broadcasted(*, c, b)), mapped((x, y) -> x + c * y, a, b), a + c * b),
  )
    m = Mapped(bc)
    @test copy(m) ≈ ref
    @test copy(m′) ≈ ref
    @test map(m.f, m.args...) ≈ ref
    @test map(m′.f, m′.args...) ≈ ref
    @test axes(m) == axes(bc)
    @test axes(m′) == axes(bc)
    @test copyto!(similar(m, elt), m) ≈ ref
    @test copyto!(similar(m′, elt), m) ≈ ref
    x = similar(m, Float32, Base.OneTo.((3, 2)))
    @test x isa Matrix{Float32}
    @test size(x) == (3, 2)
  end

  @test @inferred is_map_expr(
    Broadcast.broadcasted(+, [2], Broadcast.broadcasted(sin, [2]))
  )
  @test @inferred !is_map_expr(Broadcast.broadcasted(+, 2, Broadcast.broadcasted(sin, [2])))

  # Logic handling singleton dimensions in broadcasting.
  for (a, b) in (
    (randn(elt, 2, 2), randn(elt, 2)),
    (randn(elt, 2, 2), randn(elt, 1, 2)),
    (randn(elt, 2, 1), randn(elt, 1, 2)),
    (randn(elt, 2, 2, 2), randn(elt, 2)),
    (randn(elt, 2, 2, 2), randn(elt, 1, 2)),
    (randn(elt, 2, 2, 2), randn(elt, 1, 1, 2)),
    (randn(elt, 2, 2, 2), randn(elt, 2, 2)),
    (randn(elt, 2, 2, 2), randn(elt, 1, 2, 2)),
  )
    @test_throws DimensionMismatch mapped(+, a, b)
    bc = broadcasted(+, a, b)
    m = Mapped(bc)
    @test copy(m) == copy(bc)
  end
end

@testset "Scalar RHS" begin
  # Emulates the `Broadcasted` expression that gets instantiated
  # in expresions like `a .= 3` or `a .= 2 .+ 1`.
  bc = Broadcasted(+, (2, 1), (Base.OneTo(2), Base.OneTo(2)))
  m = @inferred Mapped(bc)
  @test axes(m) === (Base.OneTo(2), Base.OneTo(2))
  @test m.f === identity
  @test only(m.args) === Fill(3, 2, 2)
  dest = randn(2, 2)
  copyto!(dest, m)
  @test dest == Fill(3, 2, 2)
end

@testset "LinearCombination" begin
  a1 = randn(2, 2)
  a2 = randn(2, 2)
  c1 = 2
  c2 = 3
  f = LinearCombination((c1, c2))
  @test coefficients(f) ≡ (c1, c2)
  @test f(a1, a2) ≈ c1 * a1 + c2 * a2
end

@testset "Summed" begin
  elt = Float64
  a1 = randn(elt, 2, 2)
  a2 = randn(elt, 2, 2)

  s = Summed(a1)
  @test arguments(s) ≡ (a1,)
  @test coefficients(s) ≡ (one(elt),)

  s = -Summed(a1)
  @test arguments(s) ≡ (a1,)
  @test coefficients(s) ≡ (-one(elt),)

  s = 2 * Summed(a1)
  @test arguments(s) ≡ (a1,)
  @test coefficients(s) ≡ (2 * one(elt),)

  s = Summed(a1) * 2
  @test arguments(s) ≡ (a1,)
  @test coefficients(s) ≡ (2 * one(elt),)

  s = Summed(a1) / 2
  @test arguments(s) ≡ (a1,)
  @test coefficients(s) ≡ (one(elt) / 2,)

  s = 2 * Summed(a1) + 3 * Summed(a2)
  @test arguments(s) ≡ (a1, a2)
  @test coefficients(s) ≡ (2 * one(elt), 3 * one(elt))

  s = 2 * Summed(a1) - 3 * Summed(a2)
  @test arguments(s) ≡ (a1, a2)
  @test coefficients(s) ≡ (2 * one(elt), -3 * one(elt))

  s = 4 * (2 * Summed(a1) + 3 * Summed(a2))
  @test arguments(s) ≡ (a1, a2)
  @test coefficients(s) ≡ (8 * one(elt), 12 * one(elt))

  s = 2 * Summed(a1) + 3 * Summed(a2)
  @test arguments(s) ≡ (a1, a2)
  @test coefficients(s) ≡ (2 * one(elt), 3 * one(elt))
  @test LinearCombination(s) ≡ LinearCombination((2 * one(elt), 3 * one(elt)))
  @test style(s) ≡ BroadcastStyle(typeof(a1))
  @test axes(s) ≡ axes(a1)
  @test similar(s) isa typeof(a1)
  @test axes(similar(s)) ≡ axes(a1)
  @test similar(s, Float32) isa typeof(similar(a1, Float32))
  @test axes(similar(s, Float32)) ≡ axes(a1)
  @test similar(s, Base.OneTo.((3, 3))) isa typeof(similar(a1))
  @test axes(similar(s, Base.OneTo.((3, 3)))) ≡ Base.OneTo.((3, 3))
  @test similar(s, Float32, Base.OneTo.((3, 3))) isa typeof(similar(a1, Float32))
  @test axes(similar(s, Float32, Base.OneTo.((3, 3)))) ≡ Base.OneTo.((3, 3))
  @test copy(s) ≈ 2 * a1 + 3 * a2
  @test copyto!(similar(s), s) ≈ 2 * a1 + 3 * a2
  @test s[1, 2] ≈ 2 * a1[1, 2] + 3 * a2[1, 2]

  @test Broadcasted(s) isa Broadcasted
  @test Broadcasted(s).style ≡ BroadcastStyle(typeof(a1))
  @test Broadcasted(s).f ≡ LinearCombination(s)
  @test Broadcasted(s).args ≡ (a1, a2)
  @test similar(Broadcasted(s), Float32) isa typeof(similar(a1, Float32))
  @test copy(Broadcasted(s)) ≈ 2 * a1 + 3 * a2
  @test broadcastable(s) ≡ s
  @test materialize(s) ≈ 2 * a1 + 3 * a2
  @test materialize!(similar(s), s) ≈ 2 * a1 + 3 * a2
end
