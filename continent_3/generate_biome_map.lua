
local function biome(x, y)
    local a = _state.elevation_map[x][y]
    local b = _state.temperature_map[x][y]
    local c = _state.rain_map[x][y]
    if a > WATER_LEVEL then
        if b > 0.65 then
            if c > 0.60 then
                return 1
            elseif c > 0.40 then
                return 2
            else
                return 3
            end
        elseif b > 0.35 then
            if c > 0.60 then
                return 4
            elseif c > 0.40 then
                return 5
            else
                return 6
            end
        elseif b > 0.25 then
            return 7
        else 
            return 8
        end
    end
end

function generate_biome_map()
    print("generating biome map")
    _state.biome_map = generate_map(biome)
end

