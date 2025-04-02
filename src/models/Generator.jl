abstract type Generator end

struct CostSegment
    power::Float64  # Breakpoint power level (MW)
    cost::Float64   # Corresponding cost ($)
end

mutable struct ThermalGenerator <: Generator
    name::String
    fuel::String
    min::Float64
    max::Float64
    cost_curve_type::String  # Type of cost function ("piecewise" or "polynomial")
    variable_cost_coeffs::Vector{Float64}  # Polynomial cost coefficients
    cost_curve::Vector{CostSegment}  # Piecewise linear cost

    # Inner constructor (required to use `new`)
    function ThermalGenerator(
        name::String, 
        fuel_type::String, 
        min::Union{Nothing, Float64}=nothing, 
        max::Union{Nothing, Float64}=nothing;
        cost_curve::Union{Nothing, Vector{CostSegment}}=nothing,
        cost_coeffs::Union{Nothing, Vector{Float64}}=nothing)

        if isnothing(cost_coeffs) && isnothing(cost_curve)
            error("At least one cost function (piecewise or polynomial) must be provided")
        end

       # If cost_curve is provided, use its power values to define min and max
        if !isnothing(cost_curve)
            cost_curve_type = "piecewise"  # Set the type of cost function
            min = cost_curve[1].power  # Extract minimum power
            max = cost_curve[end].power  # Extract maximum power
            cost_coeffs = Vector{Float64}()  # Ensure cost_coeffs is an empty vector
        elseif !isnothing(cost_coeffs)
            cost_curve_type = "polynomial"  # Set the type of cost function
            cost_curve = Vector{CostSegment}()  # Ensure cost_curve is an empty vector
        end

        return new(name, fuel_type, min, max, cost_curve_type, cost_coeffs, cost_curve)  
    end
end


mutable struct WindGenerator <: Generator
    name::String
    fuel::String
    min::Float64
    max::Float64
    variable_cost_coeffs::Vector{Float64}  # Polynomial cost coefficients (lowest-degree first)
    cost_curve::Vector{CostSegment}  # Piecewise linear cost

    function WindGenerator(name::String, max::Float64;
        cost_curve::Union{Nothing, Vector{CostSegment}}=nothing,
        cost_coeffs::Union{Nothing, Vector{Float64}}=nothing)

        if isnothing(cost_curve) && isnothing(poly_cost_coeffs)
            error("At least one cost function (piecewise or polynomial) must be provided")
        end

        new(name, "Wind", 0.0, max, cost_curve, poly_cost_coeffs)
    end
end

# Interface functions
get_name(g::Generator) = g.name
get_min(g::ThermalGenerator) = g.min
get_max(g::Generator) = g.max
set_name!(g::Generator, name::String) = g.name = name
set_min!(g::ThermalGenerator, min::Float64) = g.min = min
set_max!(g::Generator, max::Float64) = g.max = max

# Display function
#Base.show(io::IO, g::Generator) = print(io, "Generator(name=$(g.name), capacity=$(g.capacity))")

