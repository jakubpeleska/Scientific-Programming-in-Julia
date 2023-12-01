mutable struct TrackedReal{T<:Real}
    data::T
    grad::Union{Nothing,T}
    children::Dict
    # this field is only need for printing the graph. you can safely remove it.
    name::String
end

track(x::Real,name="") = TrackedReal(x,nothing,Dict(),name)

function Base.show(io::IO, x::TrackedReal)
    t = isempty(x.name) ? "(tracked)" : "(tracked $(x.name))"
    print(io, "$(x.data) $t")
end

function accum!(x::TrackedReal)
    if isnothing(x.grad)
        x.grad = sum(w*accum!(v) for (v,w) in x.children)
    end
    x.grad
end

function Base.:+(a::TrackedReal{T}, b::TrackedReal{T}) where T
    z = track(a.data + b.data, "+")
    a.children[z] = one(T)
    b.children[z] = one(T)
    z
end

function Base.:+(a::TrackedReal{T}, b::Real) where T
    z = track(a.data + b, "+")
    a.children[z] = one(T)
    z
end

function Base.:+(a::Real, b::TrackedReal{T}) where T
    z = track(a + b.data, "+")
    b.children[z] = one(T)
    z
end

function Base.:*(a::TrackedReal, b::TrackedReal)
    z = track(a.data * b.data, "*")
    a.children[z] = b.data  # dz/da=b
    b.children[z] = a.data  # dz/db=a
    z
end

function Base.:/(a::TrackedReal{T}, b::TrackedReal{T}) where T
    z = track(a.data / b.data, "/")
    a.children[z] = 1 / b.data  # dz/da=1/b
    b.children[z] = -a.data/b.data^2  # dz/db=-a/b^2
    z
end

function Base.:/(a::TrackedReal{T}, b::Real) where T
    z = track(a.data / b, "/")
    a.children[z] = 1 / b  # dz/da=1/b
    z
end

function Base.:/(a::Real, b::TrackedReal{T}) where T
    z = track(a / b.data, "/")
    b.children[z] = -a/b.data^2  # dz/db=-a/b^2
    z
end

function Base.sin(x::TrackedReal)
    z = track(sin(x.data), "sin")
    x.children[z] = cos(x.data)
    z
end

function gradient(f, args::Real...)
    ts = track.(args)
    y  = f(ts...)
    y.grad = 1.0
    accum!.(ts)
end

function descend(f::Function, λ::Real, args::Real...)
    Δargs = gradient(f, args...)
    args .- λ .* Δargs
end


babysqrt(x, t=(1+x)/2, n=10) = n==0 ? t : babysqrt(x, (t+x/t)/2, n-1)

