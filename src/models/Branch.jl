struct Branch
    from_bus::Bus   # The sending-end bus
    to_bus::Bus     # The receiving-end bus
    resistance::Float64  # Line resistance (R)
    reactance::Float64   # Line reactance (X)
    susceptance::Float64 # Line charging susceptance (B)
    limit::Float64       # Transmission line power limit (MVA)

    function Branch(from_bus::Bus, to_bus::Bus, resistance::Float64, reactance::Float64;
                    susceptance::Float64=0.0, limit::Float64=Inf)
        new(from_bus, to_bus, resistance, reactance, susceptance, limit)
    end
end
