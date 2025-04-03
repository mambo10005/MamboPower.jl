using HiGHS
using JuMP

struct PowerSystem
    generators::Vector{<:Generator}  # Accept any subtype of Generator
    buses::Vector{Bus}
    demand::Float64
end

# Constructor allowing custom generators and optional buses
function PowerSystem(generators::Vector{<:Generator}, buses::Union{Nothing, Vector{Bus}}=nothing, demand::Float64=0.0)
    if buses === nothing
        println("No buses provided. Assigning default bus.")
        buses = Bus[]  # Ensure it's an empty vector of `Bus`
    end
    return PowerSystem(generators, buses, demand)
end

# Default constructor for an empty system
function PowerSystem()
    return PowerSystem(ThermalGenerator[], Bus[], 0.0)
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

    # Check if all generators have the same cost function type
    cost_types = unique([gen.cost_curve_type for gen in system.generators])
    if length(cost_types) > 1
        error("Mixed cost function types found. Economic dispatch must be solved separately for each type.")
    end

    # Define decision variables based on cost type
    if cost_types[1] == "piecewise"

        # Create segment-wise decision variables
        @variable(model, g_segment[i=1:generators_count, j=1:(length(system.generators[i].cost_curve) - 1)], 
            lower_bound=0, 
            upper_bound=(system.generators[i].cost_curve[j+1].power - system.generators[i].cost_curve[j].power))

        # Power balance constraint
        @constraint(model, 
            sum(system.generators[i].cost_curve[1].power for i in 1:generators_count) + 
            sum(sum(g_segment[i, j] for j in 1:(length(system.generators[i].cost_curve) - 1)) for i in 1:generators_count) 
            == system.demand
        )

        # Define cost function
        cost_expr = @expression(model, 0)
        for i in 1:generators_count
            cost_expr += system.generators[i].cost_curve[1].cost  # Fixed cost at min power
            for j in 1:(length(system.generators[i].cost_curve) - 1)
                slope = (system.generators[i].cost_curve[j+1].cost - system.generators[i].cost_curve[j].cost) /
                        (system.generators[i].cost_curve[j+1].power - system.generators[i].cost_curve[j].power)
                cost_expr += slope * g_segment[i, j]
            end
        end
    elseif cost_types[1] == "polynomial"
        # Solve using polynomial cost functions
        @variable(
            model, 
            g[i=1:generators_count], 
            lower_bound = (system.generators[i] isa ThermalGenerator ? system.generators[i].min : 0),
            upper_bound = system.generators[i].max
        )

        # Power balance constraint
        @constraint(model, sum(g[i] for i in 1:generators_count) == system.demand)

        # Define cost function
        cost_expr = @expression(model, 0)
        for i in 1:generators_count
            gen = system.generators[i]
            for (p, coeff) in enumerate(gen.variable_cost_coeffs)
                cost_expr += coeff * g[i]^(p-1)  # Polynomial cost: sum(c * P^p)
            end
        end
    else
        error("Unsupported cost function type detected.")
    end


    @objective(model, Min, cost_expr)

#=     @variable(
        model, 
        g[i=1:generators_count], 
        lower_bound = (system.generators[i] isa ThermalGenerator ? system.generators[i].min : 0),
        upper_bound = system.generators[i].max
    )

    # Define the objective function
    @objective(
        model,
        Min,
        sum(
            sum(coeff * g[i]^(p-1) for (p, coeff) in enumerate(system.generators[i].variable_cost_coeffs) if coeff != 0)
            for i in 1:generators_count
        ),
    )
    # Define the power balance constraint
    @constraint(model, sum(g[i] for i in 1:generators_count) == system.demand) =#
    # Solve statement
    optimize!(model)
    assert_is_solved_and_feasible(model)

    # Retrieve optimal dispatch
    optimal_dispatch = Dict()

    if cost_types[1] == "piecewise"
        for i in 1:generators_count
            optimal_dispatch[i] = value(system.generators[i].cost_curve[1].power)
            for j in 1:(length(system.generators[i].cost_curve) - 1)
                optimal_dispatch[i] += value(g_segment[i, j])
            end
        end
    elseif cost_types[1] == "polynomial"
        for i in 1:generators_count
            optimal_dispatch[i] = value(g[i])
        end
    end

    # return the optimal value of the objective function and its minimizers
    return (
        g = optimal_dispatch,
        total_cost = objective_value(model),
    )

    #return "more to come"
end
