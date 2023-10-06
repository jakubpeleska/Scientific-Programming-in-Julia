abstract type Agent end
agent_count(agents::Vector{A}) where A <: Agent = mapreduce(agent_count, +, agents)



abstract type Animal <: Agent end
agent_count(a::A) where A <: Animal = 1



abstract type Plant <: Agent end
size(p::P) where P <: Plant = p.size
max_size(p::P) where P <: Plant = p.max_size
agent_count(p::P) where P <: Plant = size(p) / max_size(p)



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

function kill_agent!(a::Animal,w::World)
    delete!(w.agents, a.id)
    if w.max_id == a.id
        w.max_id = maximum(_a.id for _a in w.agents)
    end
end

function reproduce!(a::A, w::World) where A <: Animal
    a.energy /= 2
    child_id = w.max_id + 1
    a_ = A(child_id, [getproperty(a,f) for f in fieldnames(A) if f != :id]...)
    w.agents[child_id] = a_
    w.max_id = child_id
end


mutable struct Grass <: Plant
    const id::Int
    size::Int
    const max_size::Int
end

Grass(id, m = 10) = Grass(id, rand(1:m), m)

Base.show(io::IO, g::Grass) = print(io, "🌿 #$(g.id) $(round(Int, g.size/g.max_size * 100))% grown")


grass = [Grass(1,5), Grass(2), Grass(1, 5, 5)]
display(grass)



mutable struct Sheep <: Animal
    const id::Int
    energy::Real
    Δenergy::Real
    reprprob::Real
    foodprob::Real
end

Sheep(id::Int, E=4.0, ΔE=0.2, pr=0.8, pf=0.6) = new(id, E, ΔE, pr, pf)

Base.show(io::IO, s::Sheep) = print(io, "🐑 #$(s.id) E=$(s.energy) ΔE=$(s.Δenergy) pr=$(s.reprprob) pf=$(s.foodprob)")

# sheep = Sheep(4)
# display(sheep)



mutable struct Wolf <: Animal
    const id::Int
    energy::Real
    Δenergy::Real
    reprprob::Real
    foodprob::Real
end

Wolf(id, E=10.0, ΔE=8.0, pr=0.1, pf=0.2) = new(id, E, ΔE, pr, pf)

Base.show(io::IO, w::Wolf) = print(io, "🐺 #$(w.id) E=$(w.energy) ΔE=$(w.Δenergy) pr=$(w.reprprob) pf=$(w.foodprob)")

function eat!(wolf::Wolf, sheep::Sheep, w::World)
    wolf.energy += wolf.Δenergy * sheep.energy
    kill_agent!(sheep, w)
end

# wolf = Wolf(5)
# # display(wolf)

# world = World([grass..., sheep, wolf])
# display(world)

# eat!(wolf,sheep,world);
# display(world)

# reproduce!(wolf, world)
# display(world)

# display(agent_count(grass[1]))
# display(agent_count(grass[2]))
# display(agent_count(grass[3]))
# display(agent_count(wolf))

# display(agent_count(grass))

# sheep = Sheep(3,10.0,5.0,1.0,1.0);

# wolf  = Wolf(4,20.0,10.0,1.0,1.0);

# world = World([grass[1], grass[2], sheep, wolf]);
# display(agent_count(world))
