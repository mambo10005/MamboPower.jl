@testset "PGOC Ex 3A" begin
    # Create generators
    gen1 = MamboPower.ThermalGenerator("Gen1", "Coal", 150.0, 600.0, cost_coeffs = [561.0, 7.92, 0.001562])
    gen2 = MamboPower.ThermalGenerator("Gen2", "Oil", 100.0, 400.0, cost_coeffs = [310.0, 7.85, 0.00194])
    gen3 = MamboPower.ThermalGenerator("Gen3", "Oil", 50.0, 200.0, cost_coeffs = [78, 7.97, 0.00482])

    # Create power system
    ps = MamboPower.PowerSystem([gen1, gen2, gen3], nothing, 850.0)

    # Solve economic dispatch
    economic_dispatch_solution = MamboPower.solve_economic_dispatch(ps)

    # Check the economic dispatch solution
    tolerance = 5e-2

    @test abs(economic_dispatch_solution.g[1] - 393.2) < tolerance
    @test abs(economic_dispatch_solution.g[2] - 334.6) < tolerance
    @test abs(economic_dispatch_solution.g[3] - 122.2) < tolerance
    @test abs(sum(values(economic_dispatch_solution.g)) - 850.0) < tolerance
    
    @test abs(economic_dispatch_solution.total_cost - 8194.356) < tolerance
end

@testset "Economic Dispatch - Piecewise Linear Cost Curves" begin
    # Define generators with piecewise linear cost curves
    gen1_cost_curve = [
        MamboPower.CostSegment(0.0, 0.0),   # (Power, Cost)
        MamboPower.CostSegment(100.0, 2000.0),
        MamboPower.CostSegment(300.0, 10000.0),
        MamboPower.CostSegment(500.0, 20000.0)
    ]

    gen2_cost_curve = [
        MamboPower.CostSegment(50.0, 1000.0),
        MamboPower.CostSegment(250.0, 7000.0),
        MamboPower.CostSegment(450.0, 14000.0)
    ]

    gen3_cost_curve = [
        MamboPower.CostSegment(200.0, 5000.0),
        MamboPower.CostSegment(400.0, 10000.0)
    ]

    # Create generators
    gen1 = MamboPower.ThermalGenerator("Gen1", "Coal", cost_curve=gen1_cost_curve)
    gen2 = MamboPower.ThermalGenerator("Gen2", "Oil", cost_curve=gen2_cost_curve)
    gen3 = MamboPower.ThermalGenerator("Gen3", "Gas", cost_curve=gen3_cost_curve)

    # Define power system with a total demand of 900 MW
    ps = MamboPower.PowerSystem([gen1, gen2, gen3], nothing, 900.0)

    # Solve economic dispatch problem
    economic_dispatch_solution = MamboPower.solve_economic_dispatch(ps)

    # Define expected dispatch results (values may slightly vary)
    expected_dispatch = Dict(
        1 => 100.0,  # Gen1 supplies 500 MW
        2 => 400.0,  # Gen2 supplies 250 MW
        3 => 400.0   # Gen3 supplies 150 MW
    )

    expected_total_cost = 24250.0  # Expected total cost (adjust based on curve fitting)

    # Define tolerance for floating-point errors
    tolerance = 5e-2

    println("Dispatch Results: ", economic_dispatch_solution.g)
    println("Total Cost: ", economic_dispatch_solution.total_cost)
    println("Expected Dispatch: ", expected_dispatch)
    println("Expected Cost: ", expected_total_cost)

    # Test each generator's dispatch
    for i in 1:3
        @test abs(economic_dispatch_solution.g[i] - expected_dispatch[i]) < tolerance
    end

    # Test power balance (sum of dispatch = demand)
    @test abs(sum(values(economic_dispatch_solution.g)) - 900.0) < tolerance

    # Test total cost
    @test abs(economic_dispatch_solution.total_cost - expected_total_cost) < tolerance
end
