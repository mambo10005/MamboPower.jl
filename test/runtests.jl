using MamboPower
using Test

@testset "MamboPower.jl" begin
    gen1 = MamboPower.ThermalGenerator("Gen1", 100.0)
    gen2 = MamboPower.ThermalGenerator("Gen2", 200.0)

    ps = MamboPower.PowerSystem([gen1, gen2])

    @test length(MamboPower.get_generators(ps)) == 2
    @test MamboPower.get_generator_by_name(ps, "Gen1") == gen1
    @test MamboPower.get_generator_by_name(ps, "Gen3") == nothing
    @test MamboPower.get_capacity(MamboPower.get_generator_by_name(ps, "Gen1")) == 100.0
    @test MamboPower.get_name(MamboPower.get_generator_by_name(ps, "Gen2")) == "Gen2"
    @test MamboPower.get_capacity(MamboPower.get_generator_by_name(ps, "Gen2")) == 200.0

    economic_dispatch = MamboPower.solve_economic_dispatch(ps)
    @test typeof(economic_dispatch) == String
    @test economic_dispatch == "Solving economic dispatch."
end
