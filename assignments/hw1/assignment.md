# Homework 1: Extending `polynomial` the other way
```@raw html
<div class="admonition is-category-homework">
<header class="admonition-header">Homework (2 points)</header>
<div class="admonition-body">
```

Extend the original polynomial function to the case where `x` is a square matrix. Create a function called `circlemat`, that returns `nxn` matrix $$A(n)$$ with the following elements
```math
\left[A(n)\right]_{ij} = 
\begin{cases}
   1 &\text{if } (i = j-1 \land j > 1) \lor (i = n \land j=1) \\
   1 &\text{if } (i = j+1 \land j < n) \lor (i = 1 \land j=n) \\
   0 & \text{  otherwise}
\end{cases}
```
and evaluate the polynomial
```math
f(A) = I + A + A^2 + A^3.
```
, at point $$A = A(10)$$.

**HINTS** for matrix definition:
You can try one of these options:
- create matrix with all zeros with `zeros(n,n)`, use two nested for loops going in ranges `1:n` and if condition with logical or `||`, and `&&` 
- employ array comprehension with nested loops `[expression for i in 1:n, j in 1:n]` and ternary operator `condition ? true branch : false`

**HINTS** for `polynomial` extension:
- extend the original example (one with for-loop) to initialize the `accumulator` variable with matrix of proper size (use `size` function to get the dimension), using argument typing for `x` is preferred to distinguish individual implementations `<: AbstractMatrix`
or
- test later defined `polynomial` methods, that may work out of the box

```@raw html
</div></div>
<details class = "solution-body" hidden>
<summary class = "solution-header">Solution:</summary><p>
```

Nothing to see here.

```@raw html
</p></details>
```

# How to submit?

Put all the code for the exercise above in a file called `hw.jl` and upload it to
[BRUTE](https://cw.felk.cvut.cz/brute/).
If you have any questions, write an email to one of the [lab instructors](@ref emails) of the course.

