abstract type AnimalSpecies <: Species end
abstract type Sheep <: AnimalSpecies end
abstract type Wolf <: AnimalSpecies end

@enum Sex female male

mutable struct Animal{A<:AnimalSpecies} <: Agent{A}
    const id::Int
    energy::Float64
    const Δenergy::Float64
    const reprprob::Float64
    const foodprob::Float64
    const sex::Sex
end

function (A::Type{<:AnimalSpecies})(id::Int,E::T,ΔE::T,pr::T,pf::T,s::Sex) where T
    Animal{A}(id,E,ΔE,pr,pf,s)
end

function Base.show(io::IO, a::Animal{A}) where {A<:AnimalSpecies}
    e = a.energy
    d = a.Δenergy
    pr = a.reprprob
    pf = a.foodprob
    s = a.sex == female ? "♀" : "♂"
    print(io, "$A$s #$(a.id) E=$e ΔE=$d pr=$pr pf=$pf")
end

# note that for new species/sexes we will only have to overload `show` on the
# abstract species types like below!
Base.show(io::IO, ::Type{Sheep}) = print(io,"🐑")
Base.show(io::IO, ::Type{Wolf}) = print(io,"🐺")

# get the per species defaults back
randsex() = rand(instances(Sex))
Sheep(id; E=4.0, ΔE=0.2, pr=0.8, pf=0.6, s=randsex()) = Sheep(id, E, ΔE, pr, pf, s)
Wolf(id; E=10.0, ΔE=8.0, pr=0.1, pf=0.2, s=randsex()) = Wolf(id, E, ΔE, pr, pf, s)

agent_count(a::Animal) = 1

mates(a::Animal{A}, b::Animal{A}) where A<:AnimalSpecies = a.sex != b.sex

function find_mate(a::Animal, w::World)
    ms = filter(x->mates(x,a), w.agents |> values |> collect)
    isempty(ms) ? nothing : rand(ms)
end

function reproduce!(a::Animal{A}, w::World) where {A}
    m = find_mate(a,w)
    if isnothing(m)
        return
    end
        
    a.energy = a.energy / 2
    vals = [getproperty(a,n) for n in fieldnames(Animal) if n ∉ [:id, :sex]]
    new_id = w.max_id + 1
    ŝ = Animal{A}(new_id, vals..., randsex())
    w.agents[ŝ.id] = ŝ
    w.max_id = new_id
end

eats(::Animal{Wolf},::Animal{Sheep}) = true
eats(::Agent,::Agent) = false
eats(::Animal{Sheep},g::Plant{Grass}) = g.size > 0

function find_food(a::Animal, w::World)
    fs = filter(x->eats(a,x), w.agents |> values |> collect)
    isempty(fs) ? nothing : rand(fs)
end

eat!(::Animal, ::Agent, ::World) = nothing
eat!(::Animal, ::Nothing, ::World) = nothing

function eat!(wolf::Animal{Wolf}, sheep::Animal{Sheep}, w::World)
    wolf.energy += sheep.energy * wolf.Δenergy
    kill_agent!(sheep,w)
end

function eat!(sheep::Animal{Sheep}, grass::Plant{Grass}, w::World)
    sheep.energy += grass.size * sheep.Δenergy
    grass.size = 0
end

function agent_step!(a::Animal, w::World)
    # a.energy -= 1
    if a.foodprob >= rand()
        food = find_food(a, w)
        eat!(a, food, w)
    end

    if a.energy < 0
        kill_agent!(a, w)
    elseif a.reprprob >= rand()
        reproduce!(a, w)
    end
end
