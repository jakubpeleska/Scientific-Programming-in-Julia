function every_nth(f::Function, n::Int)
    count = 0
    function g(args...)
        count += 1
        if count % n == 0
            f(args...)
        end
    end
end
