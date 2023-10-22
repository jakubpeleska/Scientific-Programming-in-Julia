abstract type Species end

abstract type Agent{S<:Species} end

mutable struct World
    agents::Dict{Int,Agent}
    max_id::Int
end

World(as::Vector{<:Agent}) = World(Dict(a.id=>a for a in as), maximum(a.id for a in as))

function Base.show(io::IO, w::World)
    println(io, "World of $(length(w.agents)) agents with max id #$(w.max_id)")
    for (_,a) in w.agents
        println(io,"  $a")
    end
end

agent_count(agents::Vector{A}) where A <: Agent = mapreduce(agent_count, +, agents)

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
        w.max_id = maximum(keys(w.agents))
    end
end

mates(::Agent, ::Agent) = false

function world_step!(world::World)
    ids = copy(keys(world.agents))

    for id in ids
        !haskey(world.agents,id) && continue

        a = world.agents[id]
        agent_step!(a,world)
    end
end
