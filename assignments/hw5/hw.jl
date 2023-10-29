using BenchmarkTools

using LinearAlgebra
using Printf

function _polynomial(a, x)
    accumulator = Float64(a[end])
    for i in length(a)-1:-1:1
        accumulator = accumulator * x + a[i]
    end
    accumulator
end

# definition of polynom
struct Polynom{C}
    coefficients::C
    Polynom(coefficients::CC) where {CC} = coefficients[end] == 0 ? throw(ArgumentError("Coefficient of the highest exponent cannot be zero.")) : new{CC}(coefficients)
end

# based on https://github.com/JuliaMath/Polynomials.jl
function from_roots(roots::AbstractVector{T}; aₙ=one(T)) where {T}
    n = length(roots)
    c = zeros(T, n + 1)
    c[1] = one(T)
    for j = 1:n
        for i = j:-1:1
            c[i+1] = c[i+1] - roots[j] * c[i]
        end
    end
    return Polynom(aₙ .* reverse(c))
end

(p::Polynom)(x) = _polynomial(p.coefficients, x)
degree(p::Polynom) = length(p.coefficients) - 1

function _derivativeof(p::Polynom)
    n = degree(p)
    n > 1 ? Polynom([(i - 1) * p.coefficients[i] for i in 2:n+1]) : error("Low degree of a polynomial.")
end
LinearAlgebra.adjoint(p::Polynom) = _derivativeof(p)

function Base.show(io::IO, p::Polynom)
    n = degree(p)
    a = reverse(p.coefficients)
    for (i, c) in enumerate(a[1:end-1])
        if (c != 0)
            c < 0 && print(io, " - ")
            c > 0 && i > 1 && print(io, " + ")
            print(io, "$(abs(c))x^$(n - i + 1)")
        end
    end
    c = a[end]
    c > 0 && print(io, " + $(c)")
    c < 0 && print(io, " - $(abs(c))")
end

# default optimization parameters
atol = 1e-12
maxiter = 100
stepsize = 0.95

# definition of optimization methods
abstract type RootFindingMethod end
struct Newton <: RootFindingMethod end
struct Secant <: RootFindingMethod end
struct Bisection <: RootFindingMethod end

init!(::Bisection, p::Polynom, a::Float64, b::Float64) = sign(p(a)) != sign(p(b)) ? (a, b) : throw(ArgumentError("Signs at both ends are the same."))
init!(::RootFindingMethod, p::Polynom, a::Float64, b::Float64) = (a, b)

function step!(::Newton, p::Polynom, xᵢ::Tuple{Float64,Float64}, dx::Float64)
    _, x̃ = xᵢ
    x = x̃ - dx * p(x̃) / p'(x̃)
    x̃, x
end

function step!(::Secant, p::Polynom, xᵢ::Tuple{Float64,Float64}, dx::Float64)
    x, x̃ = xᵢ
    px = p(x̃)
    dpx = (p(x) - px) / (x - x̃)
    x̃, x̃ - dx * px / dpx
end

function step!(::Bisection, p::Polynom, xᵢ::Tuple{Float64,Float64}, ::Float64)
    x, x̃ = xᵢ
    midpoint = (x + x̃) / 2
    if sign(p(midpoint)) == sign(p(x̃))
        x̃ = midpoint
    else
        x = midpoint
    end
    x, x̃
end

function find_root(p::Polynom, rfm::RootFindingMethod=Newton, a=-5.0, b=5.0, maxiter=100, dx=0.95, atol=1e-12)
    x, x̃ = init!(rfm, p, a, b)
    for i in 1:maxiter
        x, x̃ = step!(rfm, p, (x, x̃), dx)
        val = p(x̃)
        # @printf "x = %.5f | x̃ = %.5f | p(x̃) = %g\n" x x̃ val
        if abs(val) < atol
            return x̃
        end
    end
    println("Method did not converge in $(maxiter) iterations to a root within $(atol) tolerance.")
    return x̃
end


function benchmark1(p::Polynom, maxiter=100, stepsize=0.95, atol=1e-12)
    find_root(p, Bisection(), -5.0, 5.0, maxiter, stepsize, atol)
end

function benchmark2(p::Polynom, maxiter=100, stepsize=0.95, atol=1e-12)
    find_root(p, Newton(), -5.0, 5.0, maxiter, stepsize, atol)
end

function benchmark3(p::Polynom, maxiter=100, stepsize=0.95, atol=1e-12)
    find_root(p, Secant(), -5.0, 5.0, maxiter, stepsize, atol)
end

function run_test()
    p = Polynom([0,-36,0,49,0,-14,0,1])
    # @code_warntype find_root(p, Bisection(), -5.0, 5.0, maxiter, stepsize, atol)
    # @code_warntype step!(Bisection(), p, (-5.0, 5.0), stepsize)
    # @code_warntype find_root(p, Newton(), -5.0, 5.0, maxiter, stepsize, atol)
    # @code_warntype step!(Newton(), p, (-5.0, 5.0), stepsize)
    # @code_warntype find_root(p, Secant(), -5.0, 5.0, maxiter, stepsize, atol)
    # @code_warntype step!(Secant(), p, (-5.0, 5.0), stepsize)

    for _ in 1:1000
        x = benchmark1(p)
        x = benchmark2(p)
        x = benchmark3(p)
    end
end

