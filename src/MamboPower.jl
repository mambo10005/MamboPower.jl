module MamboPower

#__precompile__(false)

export PowerSystem, Generator, solve_economic_dispatch

include("models/Generator.jl")
include("models/PowerSystem.jl")


end