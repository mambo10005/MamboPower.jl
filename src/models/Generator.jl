abstract type Generator end

mutable struct ThermalGenerator <: Generator
    name::String
    capacity::Float64
end

# Interface functions
get_name(g::Generator) = g.name
get_capacity(g::Generator) = g.capacity

# Display function
Base.show(io::IO, g::Generator) = print(io, "Generator(name=$(g.name), capacity=$(g.capacity))")

