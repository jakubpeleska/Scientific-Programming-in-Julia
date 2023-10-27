module Ecosystem

using StatsBase

include("world.jl")
include("plant.jl")
include("animal.jl")

export World
export Species, PlantSpecies, AnimalSpecies, Grass, Sheep, Wolf
export Agent, Plant, Animal
export male, female
export agent_step!, eat!, eats, find_food, reproduce!, world_step!, agent_count

end