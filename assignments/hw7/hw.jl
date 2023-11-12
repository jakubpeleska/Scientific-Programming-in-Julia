# using Ecosystem

default_config(::Type{Grass}) = (size=rand(1:10),max_size=10)
default_config(::Type{Sheep}) = (E=4.0, ΔE=0.2, pr=0.8, pf=0.6)
default_config(::Type{Wolf}) = (E=10.0, ΔE=8.0, pr=0.1, pf=0.2)

function _add_agents(max_id, count::Int, species::Type{<:PlantSpecies})
    [species(i, default_config(species)...) for i in max_id+1:max_id + count]
end

function _add_agents(max_id, count::Int, species::Type{<:AnimalSpecies})
    [species(i, default_config(species)..., randsex()) for i in max_id+1:max_id + count]
end

function _add_agents(max_id, count::Int, species::Type{<:AnimalSpecies}, sex::Sex)
    [species(i, default_config(species)..., sex) for i in max_id+1:max_id + count]
end

function _ecosystem(world_ex::Expr)
    agents = []
    for el_ex in world_ex.args
        if typeof(el_ex) == LineNumberNode
            continue
        end
        if length(el_ex.args) < 4
            continue # optionaly throw an error
        end
        if el_ex.args[1] == Symbol("@add")
            if length(el_ex.args) == 4
                append!(agents, _add_agents(length(agents), el_ex.args[3], eval(el_ex.args[4])))
            elseif length(el_ex.args) == 5
                append!(agents,_add_agents(length(agents), el_ex.args[3], eval(el_ex.args[4]), eval(el_ex.args[5])))
            end
        end
    end

    World(Dict(a.id=>a for a in agents), length(agents))
end

macro ecosystem(ex::Expr)
    _ecosystem(ex)
end

# ex = :(begin
#     @add 10 Sheep female
#     @add 2 Sheep male
#     @add 1 Grass
#     @add 3 Wolf
# end)
# genex = _ecosystem(ex)
# world = eval(genex)

# world = @ecosystem begin
#     @add 10 Sheep female    # adds 10 female sheep
#     @add 2 Sheep male       # adds 2 male sheep
#     @add 100 Grass          # adds 100 pieces of grass
#     @add 3 Wolf             # adds 5 wolf with random sex
# end

# display(world.max_id)
