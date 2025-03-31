using MamboPower
using Test

@testset "MamboPower.jl" begin
    gen1 = MamboPower.ThermalGenerator("Gen1", 0.0, 1000.0, 50.0, 1000.0)
    gen2 = MamboPower.ThermalGenerator("Gen2", 300.0, 1000.0, 100.0, 0.0)
    gen3 = MamboPower.WindGenerator("Gen3", 200.0, 50.0)

    ps = MamboPower.PowerSystem([gen1, gen2, gen3], 1500.0)

    @test length(MamboPower.get_generators(ps)) == 3
    @test MamboPower.get_generator_by_name(ps, "Gen1") == gen1
    @test MamboPower.get_generator_by_name(ps, "Gen3") == gen3
    @test MamboPower.get_generator_by_name(ps, "Gen4") === nothing
    @test MamboPower.get_min(MamboPower.get_generator_by_name(ps, "Gen1")) == 0.0
    @test MamboPower.get_name(MamboPower.get_generator_by_name(ps, "Gen2")) == "Gen2"
    @test MamboPower.get_max(MamboPower.get_generator_by_name(ps, "Gen2")) == 1000.0
    @test MamboPower.get_variable_cost(MamboPower.get_generator_by_name(ps, "Gen3")) == 50.0

    economic_dispatch_solution = MamboPower.solve_economic_dispatch(ps)
    @test economic_dispatch_solution.g[1] == 1000.0
    #@test economic_dispatch_solution == "more to come"
end
