using HiGHS
using JuMP

struct PowerSystem
    generators::Vector{Generator}
    demand::Float64
end

function PowerSystem(generators::Vector{Generator})
    return PowerSystem(generators, 0.0)
end

function PowerSystem()
    return PowerSystem([], 0.0)
end

function get_generators(ps::PowerSystem)
    return ps.generators
end

function get_generator_by_index(ps::PowerSystem, index::Int)
    if index < 1 || index > length(ps.generators)
        throw(ArgumentError("Index out of bounds."))
    end
    return ps.generators[index]
end

function get_generator_by_name(ps::PowerSystem, name::String)
    for g in ps.generators
        if g.name == name
            return g
        end
    end
    return nothing
end

function get_demand(ps::PowerSystem)
    return ps.demand
end

function set_generators!(ps::PowerSystem, generators::Vector{Generator})
    ps.generators = generators
    return ps
end

function add_generator(ps::PowerSystem, generator::Generator)
    push!(ps.generators, generator)
    return ps
end

function remove_generator(ps::PowerSystem, generator_name::String)
    ps.generators = filter(g -> g.name != generator_name, ps.generators)
    return ps
end

function set_demand!(ps::PowerSystem, demand::Float64)
    ps.demand = demand
    return ps
end

function solve_economic_dispatch(system::PowerSystem)
    # Define the economic dispatch (ED) model
    model = Model(HiGHS.Optimizer)
    set_silent(model)

    generators_count = length(system.generators)

    # Define variables based on generator type
    @variable(
        model, 
        g[i=1:generators_count], 
        lower_bound = (system.generators[i] isa ThermalGenerator ? system.generators[i].min : 0),
        upper_bound = system.generators[i].max
    )

    # Define the objective function
    @objective(
        model,
        Min,
        sum(system.generators[i].variable_cost * g[i] for i in 1:generators_count),
    )
    # Define the power balance constraint
    @constraint(model, sum(g[i] for i in 1:generators_count) == system.demand)
    # Solve statement
    optimize!(model)
    assert_is_solved_and_feasible(model)
    # return the optimal value of the objective function and its minimizers
    return (
        g = value.(g),
        total_cost = objective_value(model),
    )

    #return "more to come"
end
