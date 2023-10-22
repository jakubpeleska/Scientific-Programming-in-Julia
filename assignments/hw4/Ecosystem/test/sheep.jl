@testset "Sheep" begin
    sheep = Sheep(1,1,1,0,1,male)
    grass = Grass(2,10,10)
    world = World([sheep, grass])
    eat!(sheep, grass, world)
    @test grass.size == 0
end
