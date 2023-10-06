function circlemat(n::Int)
    A = [
        i == j - 1 ||
        i == j + 1 ||
        (i == 1 && j == n) ||
        (j == 1 && i == n) ? 
        1. : 0. 
        for j in 1:n for i in 1:n
    ]
    return reshape(A, n, n)
end

function polynomial(a, x)
    if eltype(a) == Char
        throw(ArgumentError("Invalid type of input $(a) of type Char!"))
    end
    accumulator = 0
    if typeof(x) <: AbstractMatrix
        accumulator = zeros(size(x))
    end
    for i in length(a):-1:1
        accumulator += x^(i-1) * a[i] # ! 1-based indexing for arrays
    end
    return accumulator
end

a = ones(4)
X = circlemat(10)
display(polynomial(a,X))
