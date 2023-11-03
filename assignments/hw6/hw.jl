
function find_variables(expr::Expr)::Vector{Symbol}
    args = expr.args
    if occursin(r"^.\(", string(expr))
        args = args[2:end]
    end

    vars = Vector{Symbol}()
    for arg in args
        if typeof(arg) == Symbol && occursin(r"^[a-zA-Z]$", string(arg))
            push!(vars, arg)
        elseif typeof(arg) == Expr
            append!(vars, find_variables(arg))
        end
    end
    return sort!(unique(vars))
end

e1 = :(x = i + j + f(g(d + h(d))))
e2 = :(x = l(g(x)) + f(g(y + h(z))))
e3 = :(x = l())
e4 = :(l())

vars1 = find_variables(e1)
vars2 = find_variables(e2)
vars3 = find_variables(e3)
vars4 = find_variables(e4)

# display(vars1)
# display(vars2)
# display(vars3)
# display(vars4)

@assert vars1 == [:d, :i, :j, :x]
@assert vars2 == [:x, :y, :z]
@assert vars3 == [:x]
@assert vars4 == []



