@testset "Wolf" begin
    wolf = Wolf(1,1,1,0,1,male)
    sheep = Sheep(2,1,1,0,0,male)
    world = World([wolf, sheep])
    eat!(wolf, sheep, world)
    @test length(keys(world.agents)) == 1
end
