using Base.Broadcast: Broadcasted
struct LinearCombination{C} <: Function
    coefficients::C
end
coefficients(a::LinearCombination) = a.coefficients
function (f::LinearCombination)(args...)
    return mapreduce(*, +, coefficients(f), args)
end

struct Summed{Style, N, C <: NTuple{N, Any}, A <: NTuple{N, Any}}
    style::Style
    coefficients::C
    arguments::A
end
Summed(a::Summed) = a
coefficients(a::Summed) = a.coefficients
arguments(a::Summed) = a.arguments
style(a::Summed) = a.style
LinearCombination(a::Summed) = LinearCombination(coefficients(a))
using Base.Broadcast: combine_axes
Base.axes(a::Summed) = combine_axes(a.arguments...)
function Base.eltype(a::Summed)
    cts = typeof.(coefficients(a))
    elts = eltype.(arguments(a))
    ts = map((ct, elt) -> Base.promote_op(*, ct, elt), cts, elts)
    return Base.promote_op(+, ts...)
end
function Base.getindex(a::Summed, I...)
    return mapreduce(+, coefficients(a), arguments(a)) do c, a
        return c * a[I...]
    end
end
using Base.Broadcast: combine_styles
function Summed(coefficients::Tuple, arguments::Tuple)
    return Summed(combine_styles(arguments...), coefficients, arguments)
end
Summed(a) = Summed((one(eltype(a)),), (a,))
function Base.:+(a::Summed, b::Summed)
    return Summed(
        (coefficients(a)..., coefficients(b)...), (arguments(a)..., arguments(b)...)
    )
end
Base.:-(a::Summed, b::Summed) = a + (-b)
Base.:+(a::Summed, b::AbstractArray) = a + Summed(b)
Base.:-(a::Summed, b::AbstractArray) = a - Summed(b)
Base.:+(a::AbstractArray, b::Summed) = Summed(a) + b
Base.:-(a::AbstractArray, b::Summed) = Summed(a) - b
Base.:*(c::Number, a::Summed) = Summed(c .* coefficients(a), arguments(a))
Base.:*(a::Summed, c::Number) = c * a
Base.:/(a::Summed, c::Number) = Summed(coefficients(a) ./ c, arguments(a))
Base.:-(a::Summed) = -one(eltype(a)) * a

Base.similar(a::Summed) = similar(a, eltype(a))
Base.similar(a::Summed, elt::Type) = similar(a, elt, axes(a))
Base.similar(a::Summed, ax::Tuple) = similar(a, eltype(a), ax)
function Base.similar(a::Summed, elt::Type, ax::Tuple)
    return similar(Broadcasted(a), elt, ax)
end
Base.copy(a::Summed) = copyto!(similar(a), a)
function Base.copyto!(dest::AbstractArray, a::Summed)
    return copyto!(dest, Broadcasted(a))
end
function Broadcast.Broadcasted(a::Summed)
    f = LinearCombination(a)
    return Broadcasted(style(a), f, arguments(a), axes(a))
end

using Base.Broadcast: Broadcast
Broadcast.BroadcastStyle(a::Type{<:Summed{<:Style}}) where {Style} = Style()
Broadcast.broadcastable(a::Summed) = a
Broadcast.materialize(a::Summed) = copy(a)
Broadcast.materialize!(dest, a::Summed) = copyto!(dest, a)
