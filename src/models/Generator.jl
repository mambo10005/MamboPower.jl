abstract type Generator end

mutable struct ThermalGenerator <: Generator
    name::String
    min::Float64
    max::Float64
    variable_cost::Float64
    fixed_cost::Float64
end

mutable struct WindGenerator <: Generator
    name::String
    max::Float64
    variable_cost::Float64
end

# Interface functions
get_name(g::Generator) = g.name
get_min(g::ThermalGenerator) = g.min
get_max(g::Generator) = g.max
get_variable_cost(g::Generator) = g.variable_cost
get_fixed_cost(g::ThermalGenerator) = g.fixed_cost
set_name!(g::Generator, name::String) = g.name = name
set_min!(g::ThermalGenerator, min::Float64) = g.min = min
set_max!(g::Generator, max::Float64) = g.max = max
set_variable_cost!(g::Generator, variable_cost::Float64) = g.variable_cost = variable_cost
set_fixed_cost!(g::ThermalGenerator, fixed_cost::Float64) = g.fixed_cost = fixed_cost

# Display function
#Base.show(io::IO, g::Generator) = print(io, "Generator(name=$(g.name), capacity=$(g.capacity))")

