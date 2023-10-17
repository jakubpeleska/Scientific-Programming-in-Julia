abstract type Species end

abstract type PlantSpecies <: Species end
abstract type Grass <: PlantSpecies end

abstract type AnimalSpecies <: Species end
abstract type Sheep <: AnimalSpecies end
abstract type Wolf <: AnimalSpecies end

abstract type Agent{S<:Species} end

function every_nth(f::Function, n::Int)
    count = 0
    function g(args...)
        count += 1
        if count % n == 0
            f(args...)
        end
    end
end

agent_count(agents::Vector{A}) where A <: Agent = mapreduce(agent_count, +, agents)

# instead of Symbols we can use an Enum for the sex field
# using an Enum here makes things easier to extend in case you
# need more than just binary sexes and is also more explicit than
# just a boolean
@enum Sex female male

mutable struct World{A<:Agent}
    agents::Dict{Int,A}
    max_id::Int
end

World(as::Vector{<:Agent}) = World(Dict(a.id=>a for a in as), maximum(a.id for a in as))

function Base.show(io::IO, w::World)
    println(io, "World of $(length(w.agents)) agents with max id #$(w.max_id)")
    for (_,a) in w.agents
        println(io,"  $a")
    end
end

function agent_count(w::World)
    counts = Dict{Symbol, Real}()
    for (_, a) in w.agents
        s = nameof(typeof(a))
        counts[s] = get!(counts, s, 0) + agent_count(a)
    end
    return counts
end

function kill_agent!(a::Agent,w::World)
    delete!(w.agents, a.id)
    if w.max_id == a.id
        w.max_id = maximum(_a.id for _a in w.agents)
    end
end

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

agent_count(a::Animal) = 1


# note that for new species/sexes we will only have to overload `show` on the
# abstract species types like below!
Base.show(io::IO, ::Type{Sheep}) = print(io,"🐑")
Base.show(io::IO, ::Type{Wolf}) = print(io,"🐺")

# get the per species defaults back
randsex() = rand(instances(Sex))
Sheep(id; E=4.0, ΔE=0.2, pr=0.8, pf=0.6, s=randsex()) = Sheep(id, E, ΔE, pr, pf, s)
Wolf(id; E=10.0, ΔE=8.0, pr=0.1, pf=0.2, s=randsex()) = Wolf(id, E, ΔE, pr, pf, s)

mates(a::Animal{A}, b::Animal{A}) where A<:AnimalSpecies = a.sex != b.sex
mates(::Agent, ::Agent) = false

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

function eat!(wolf::Animal{Wolf}, sheep::Animal{Sheep}, w::World)
    wolf.energy += sheep.energy * wolf.Δenergy
    kill_agent!(sheep,w)
end

eats(::Animal{Wolf},::Animal{Sheep}) = true
eats(::Agent,::Agent) = false

function find_food(a::Animal, w::World)
    fs = filter(x->eats(a,x), w.agents |> values |> collect)
    isempty(fs) ? nothing : rand(fs)
end


mutable struct Plant{P<:PlantSpecies} <: Agent{P}
    const id::Int
    size::Int
    const max_size::Int
end

# constructor for all Plant{<:PlantSpecies} callable as PlantSpecies(...)
(A::Type{<:PlantSpecies})(id, s, m) = Plant{A}(id,s,m)
(A::Type{<:PlantSpecies})(id, m) = (A::Type{<:PlantSpecies})(id,rand(1:m),m)

# default specific for Grass
Grass(id; max_size=10) = Grass(id, rand(1:max_size), max_size)

function Base.show(io::IO, p::Plant{P}) where P
    x = p.size/p.max_size * 100
    print(io,"$P  #$(p.id) $(round(Int,x))% grown")
end

Base.show(io::IO, ::Type{Grass}) = print(io,"🌿")

size(p::Plant) = p.size
max_size(p::Plant) = p.max_size
agent_count(p::Plant) = size(p) / max_size(p)

function eat!(sheep::Animal{Sheep}, grass::Plant{Grass}, w::World)
    sheep.energy += grass.size * sheep.Δenergy
    grass.size = 0
end
eats(::Animal{Sheep},g::Plant{Grass}) = g.size > 0

# wolves = [Wolf(i) for i in 1:5]

# sheeps = [Sheep(i,pf=1.0) for i in 6:10]

# grass = [Grass(i) for i in 11:15]

# # display(wolves)

# world = World([wolves..., sheeps..., grass...])

# display(agent_count(world))

# display(find_food(sheeps[1], world) isa Plant{Grass})

# logcb = every_nth(w->(@info agent_count(w)), 3)

# logcb(world)
# logcb(world)
# logcb(world)