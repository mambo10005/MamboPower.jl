include("Generator.jl")

struct PowerSystem
    generators::Vector{Generator}
end

function PowerSystem()
    gen1 = MamboPower.ThermalGenerator("Gen1", 100.0)
    gen2 = MamboPower.ThermalGenerator("Gen2", 200.0)
    return PowerSystem([gen1, gen2])  # Initialize with an empty list of generators
end

function add_generator(ps::PowerSystem, generator::Generator)
    push!(ps.generators, generator)
    return ps
end

function remove_generator(ps::PowerSystem, generator_name::String)
    ps.generators = filter(g -> g.name != generator_name, ps.generators)
    return ps
end

get_generators(ps::PowerSystem) = ps.generators

function get_generator_by_name(ps::PowerSystem, name::String)
    for g in ps.generators
        if g.name == name
            return g
        end
    end
    return nothing
end

solve_economic_dispatch(ps::PowerSystem) = "Solving economic dispatch."
