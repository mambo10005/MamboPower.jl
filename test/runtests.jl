using MamboPower
using Test

@testset "MamboPower.jl" begin
    @testset "PowerSystem" begin
         # Create buses
        bus1 = Bus(1, "Bus1", 1.0, 500.0)
        bus2 = Bus(2, "Bus2", 1.0, 300.0)

        gen1_cost_curve = [MamboPower.CostSegment(0.0, 0.0), MamboPower.CostSegment(1000.0, 50000.0)]
        gen2_cost_curve = [MamboPower.CostSegment(300.0, 30000.0), MamboPower.CostSegment(1000.0, 100000.0)]
        gen3_cost_curve = [MamboPower.CostSegment(0.0, 0.0), MamboPower.CostSegment(200.0, 10000.0)]

        gen1 = MamboPower.ThermalGenerator("Gen1", "Coal", cost_curve = gen1_cost_curve, bus=bus1)
        gen2 = MamboPower.ThermalGenerator("Gen2", "Oil", cost_curve = gen2_cost_curve, bus=bus2)
        gen3 = MamboPower.ThermalGenerator("Gen3", "Unknown", cost_curve = gen3_cost_curve, bus=bus1)

        #= gen1 = MamboPower.ThermalGenerator("Gen1", "", 0.0, 1000.0, [0.0, 50.0])
        gen2 = MamboPower.ThermalGenerator("Gen2", "", 300.0, 1000.0, [0.0, 100.0])
        gen3 = MamboPower.WindGenerator("Gen3", 200.0, [0.0, 50.0]) =#

        ps = MamboPower.PowerSystem([gen1, gen2, gen3], [bus1, bus2], 1500.0)

        @test length(MamboPower.get_generators(ps)) == 3
        @test MamboPower.get_generator_by_name(ps, "Gen1") == gen1
        @test MamboPower.get_generator_by_name(ps, "Gen3") == gen3
        @test MamboPower.get_generator_by_name(ps, "Gen4") === nothing
        @test MamboPower.get_min(MamboPower.get_generator_by_name(ps, "Gen1")) == 0.0
        @test MamboPower.get_name(MamboPower.get_generator_by_name(ps, "Gen2")) == "Gen2"
        @test MamboPower.get_max(MamboPower.get_generator_by_name(ps, "Gen2")) == 1000.0

        economic_dispatch_solution = MamboPower.solve_economic_dispatch(ps)
        @test economic_dispatch_solution.g[1] == 1000.0
        @test economic_dispatch_solution.g[2] == 300.0
        @test economic_dispatch_solution.g[3] == 200.0
    end

    @testset "Economic Dispatch Tests" begin
        include("test_economic_dispatch.jl")
    end
end

